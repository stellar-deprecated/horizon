package ingest

import (
	"encoding/json"
	"fmt"
	"time"

	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/db/sqx"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/toid"
)

// Run starts an attempt to ingest the range of ledgers specified in this
// session.
func (is *Session) Run() {
	for seq := is.FirstLedger; seq <= is.LastLedger; seq++ {

		// 1. start transaction
		is.TX, is.Err = db.Begin(is.Ingester.HorizonDB)

		if is.Err != nil {
			return
		}

		is.Ingester.Metrics.TotalTimer.Time(func() {
			// Do the actual work
			is.ingestSingle(seq)
		})

		// Check and handle failure
		if is.Err != nil {
			is.Ingester.Metrics.FailedMeter.Mark(1)
			is.TX.Rollback()
			return
		}

		is.Err = is.TX.Commit()
		if is.Err != nil {
			is.Ingester.Metrics.FailedMeter.Mark(1)
			return
		}

		// Record success
		is.Ingester.Metrics.SuccessfulMeter.Mark(1)
		is.Ingested++

	}
}

// assetDetails sets the details for `a` on `result` using keys with `prefix`
func (is *Session) assetDetails(result map[string]interface{}, a xdr.Asset, prefix string) {
	var (
		t string
		c string
		i string
	)
	is.Err = a.Extract(&t, &c, &i)
	result[prefix+"asset_type"] = t

	if a.Type == xdr.AssetTypeAssetTypeNative {
		return
	}
	result[prefix+"asset_code"] = c
	result[prefix+"asset_issuer"] = i
}

func (is *Session) clearExistingDataIfNeeded(data *LedgerBundle) {
	if !is.ClearExisting {
		return
	}
	log.Infof("clearing ledger data: %d", data.Sequence)

	if data.Sequence == 1 {
		del := is.TX.Delete("history_accounts").Where("id = 1")
		is.TX.ExecDelete(del)
	}

	is.clearLedgerData(data.Sequence, "history_effects", "history_operation_id")
	is.clearLedgerData(data.Sequence, "history_operation_participants", "history_operation_id")
	is.clearLedgerData(data.Sequence, "history_operations", "id")
	is.clearLedgerData(data.Sequence, "history_transaction_participants", "history_transaction_id")
	is.clearLedgerData(data.Sequence, "history_transactions", "id")
	is.clearLedgerData(data.Sequence, "history_accounts", "id")
	is.clearLedgerData(data.Sequence, "history_ledgers", "id")
	is.Err = is.TX.Err
}

func (is *Session) clearLedgerData(seq int32, table string, idCol string) {

	start := toid.ID{LedgerSequence: seq}
	end := toid.ID{LedgerSequence: seq + 1}

	del := is.TX.Delete(table).Where(
		fmt.Sprintf("%s >= ? AND %s < ?", idCol, idCol),
		start.ToInt64(),
		end.ToInt64(),
	)
	is.TX.ExecDelete(del)
}

func (is *Session) createRootAccountIfNeeded(data *LedgerBundle) {
	if data.Sequence != 1 {
		return
	}

	ib := is.TX.Insert("history_accounts").
		Columns("id", "address").
		Values(1, keypair.Master(is.Ingester.Network).Address())

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err
}

func (is *Session) do(steps ...func()) {
	for _, step := range steps {
		if is.Err != nil {
			return
		}

		step()
	}
}

func (is *Session) extractDetails(o xdr.Operation, resolvedSource xdr.AccountId) interface{} {
	details := map[string]interface{}{}

	switch o.Body.Type {
	case xdr.OperationTypeCreateAccount:
		op := o.Body.MustCreateAccountOp()
		details["funder"] = resolvedSource.Address()
		details["account"] = op.Destination.Address()
		details["starting_balance"] = amount.String(op.StartingBalance)
	case xdr.OperationTypePayment:
		op := o.Body.MustPaymentOp()
		details["from"] = resolvedSource.Address()
		details["to"] = op.Destination.Address()
		details["amount"] = amount.String(op.Amount)
		is.assetDetails(details, op.Asset, "")
	case xdr.OperationTypePathPayment:
		//TODO
	case xdr.OperationTypeManageOffer:
		//TODO
	case xdr.OperationTypeCreatePassiveOffer:
		//TODO
	case xdr.OperationTypeSetOptions:
		//TODO
	case xdr.OperationTypeChangeTrust:
		op := o.Body.MustChangeTrustOp()
		is.assetDetails(details, op.Line, "")
		details["trustor"] = resolvedSource.Address()
		details["trustee"] = details["asset_issuer"]
		details["limit"] = amount.String(op.Limit)
	case xdr.OperationTypeAllowTrust:
		op := o.Body.MustAllowTrustOp()
		is.assetDetails(details, op.Asset.ToAsset(resolvedSource), "")
		details["trustee"] = resolvedSource.Address()
		details["trustor"] = op.Trustor.Address()
		details["authorize"] = op.Authorize
	case xdr.OperationTypeAccountMerge:
		aid := o.Body.MustDestination()
		details["account"] = resolvedSource.Address()
		details["into"] = aid.Address()
	case xdr.OperationTypeInflation:
		// no inflation details, presently
	case xdr.OperationTypeManageData:
		op := o.Body.MustManageDataOp()
		details["name"] = string(op.DataName)
		if op.DataValue != nil {
			details["value"], is.Err = xdr.MarshalBase64(*op.DataValue)
		} else {

			details["value"] = nil
		}
	default:
		is.Err = fmt.Errorf("Unknown operation type: %s", o.Body.Type)
	}

	return details
}

func (is *Session) formatTimeBounds(bounds *xdr.TimeBounds) interface{} {
	if bounds == nil {
		return nil
	}

	return sq.Expr("?::int8range", fmt.Sprintf("[%d,%d]", bounds.MinTime, bounds.MaxTime))
}

func (is *Session) ingestHistoryLedger(data *LedgerBundle) {

	ib := is.TX.Insert("history_ledgers").Columns(
		"importer_version",
		"id",
		"sequence",
		"ledger_hash",
		"previous_ledger_hash",
		"total_coins",
		"fee_pool",
		"base_fee",
		"base_reserve",
		"max_tx_set_size",
		"closed_at",
		"created_at",
		"updated_at",
	).Values(
		CurrentVersion,
		toid.New(data.Sequence, 0, 0).ToInt64(),
		data.Sequence,
		data.Header.LedgerHash,
		data.Header.PrevHash,
		data.Header.Data.TotalCoins,
		data.Header.Data.FeePool,
		data.Header.Data.BaseFee,
		data.Header.Data.BaseReserve,
		data.Header.Data.MaxTxSetSize,
		time.Unix(data.Header.CloseTime, 0).UTC(),
		time.Now().UTC(),
		time.Now().UTC(),
	)

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err

}

func (is *Session) ingestHistoryAccounts(data *LedgerBundle) {
	na := data.NewAccounts()

	if len(na) == 0 {
		return
	}

	ib := is.TX.Insert("history_accounts").Columns("id", "address")
	for _, account := range na {
		ib = ib.Values(account.ID, account.Address)
	}
	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err
}

func (is *Session) ingestHistoryTransactions(data *LedgerBundle) {
	for i := range data.Transactions {
		is.ingestHistoryTransaction(&data.Transactions[i], &data.TransactionFees[i])
		if is.Err != nil {
			return
		}
	}
}

func (is *Session) ingestHistoryTransaction(tx *core.Transaction, fee *core.TransactionFee) {

	ib := is.TX.Insert("history_transactions").Columns(
		"id",
		"transaction_hash",
		"ledger_sequence",
		"application_order",
		"account",
		"account_sequence",
		"fee_paid",
		"operation_count",
		"tx_envelope",
		"tx_result",
		"tx_meta",
		"tx_fee_meta",
		"signatures",
		"time_bounds",
		"memo_type",
		"memo",
		"created_at",
		"updated_at",
	).Values(
		toid.New(tx.LedgerSequence, tx.Index, 0).ToInt64(),
		tx.TransactionHash,
		tx.LedgerSequence,
		tx.Index,
		tx.SourceAddress(),
		tx.Sequence(),
		tx.Fee(),
		len(tx.Envelope.Tx.Operations),
		tx.EnvelopeXDR(),
		tx.ResultXDR(),
		tx.ResultMetaXDR(),
		fee.ChangesXDR(),
		sqx.StringArray(tx.Base64Signatures()),
		is.formatTimeBounds(tx.Envelope.Tx.TimeBounds),
		tx.MemoType(),
		tx.Memo(),
		time.Now().UTC(),
		time.Now().UTC(),
	)

	is.TX.ExecInsert(ib)
	is.Err = is.TX.Err

	// TODO: import transaction participants
}

func (is *Session) ingestHistoryOperations(data *LedgerBundle) {
	shouldExec := false
	ib := is.TX.Insert("history_operations").Columns(
		"id",
		"transaction_id",
		"application_order",
		"source_account",
		"type",
		"details",
	)

	for txi, tx := range data.Transactions {
		for opi, op := range tx.Envelope.Tx.Operations {
			var (
				id      int64
				txid    int64
				source  xdr.AccountId
				optype  int
				details []byte
			)

			id = toid.New(data.Sequence, int32(txi), int32(opi)).ToInt64()
			txid = toid.New(data.Sequence, int32(txi), 0).ToInt64()

			if op.SourceAccount != nil {
				source = *op.SourceAccount
			} else {
				source = tx.Envelope.Tx.SourceAccount
			}
			optype = int(op.Body.Type)
			d := is.extractDetails(op, source)
			if is.Err != nil {
				return
			}

			details, is.Err = json.Marshal(d)
			if is.Err != nil {
				return
			}

			shouldExec = true
			ib = ib.Values(id, txid, opi, source.Address(), optype, details)
		}
	}

	// Only try to insert rows if this ledger actually had content
	if shouldExec {
		is.TX.ExecInsert(ib)
		is.Err = is.TX.Err
	}

	// TODO: import operation participants

}

func (is *Session) ingestHistoryEffects(data *LedgerBundle) {

}

// injestSingle imports a single ledger (at `seq`) of data.
func (is *Session) ingestSingle(seq int32) {
	if is.Err != nil {
		return
	}

	log.Debugf("ingesting ledger %d", seq)
	data := &LedgerBundle{Sequence: seq}
	is.Err = data.Load(is.Ingester.CoreDB)
	if is.Err != nil {
		return
	}

	is.do(
		func() { is.clearExistingDataIfNeeded(data) },
		func() { is.createRootAccountIfNeeded(data) },
		func() { is.validateLedgerChain(data) },
		func() { is.ingestHistoryLedger(data) },
		func() { is.ingestHistoryAccounts(data) },
		func() { is.ingestHistoryTransactions(data) },
		func() { is.ingestHistoryOperations(data) },
		func() { is.ingestHistoryEffects(data) },
	)

	return
}

func (is *Session) validateLedgerChain(data *LedgerBundle) {
	// TODO: ensure prevhash exists in the database
}
