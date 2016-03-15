package ingest

import (
	"encoding/base64"
	"fmt"

	"github.com/stellar/horizon/ingest/participants"
	// "github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
)

// Run starts an attempt to ingest the range of ledgers specified in this
// session.
func (is *Session) Run() {
	is.Err = is.Ingestion.Start()
	if is.Err != nil {
		return
	}

	for is.Cursor.NextLedger() {
		is.clearLedger()
		is.ingestLedger()
		is.flush()
	}

	if is.Err != nil {
		is.Ingestion.Rollback()
		return
	}

	is.Err = is.Ingestion.Close()

	// TODO: metrics
	// TODO: validate ledger chain
	// TODO: clear data
	// TODO: record success

}

func (is *Session) clearLedger() {
	if is.Err != nil {
		return
	}

	if !is.ClearExisting {
		return
	}

	is.Err = is.Ingestion.Clear(is.Cursor.LedgerRange())
}

func (is *Session) flush() {
	if is.Err != nil {
		return
	}
	is.Err = is.Ingestion.Flush()
}

func (is *Session) ingestEffects() {
	if is.Err != nil {
		return
	}
	// effects := is.Ingestion.Effects(is.Cursor.OperationID())

	switch is.Cursor.OperationType() {
	case xdr.OperationTypeCreateAccount:
		op := is.Cursor.Operation().Body.MustCreateAccountOp()
		_ = op
		// effects.Add("account_created", op.Destination, map[string]interface{}{
		// 	"starting_balance": amount.String(op.StartingBalance),
		// })

		// TODO: account_debited
		// TODO: signer_created
	case xdr.OperationTypePayment:
		// TODO: account_credited
		// TODO: account_debited
	case xdr.OperationTypePathPayment:
		// TODO: account_credited
		// TODO: account_debited
		// TODO: trades
	case xdr.OperationTypeManageOffer:
		// TODO: trades
	case xdr.OperationTypeCreatePassiveOffer:
		// TODO: trades
	case xdr.OperationTypeSetOptions:
		// TODO: account_home_domain_updated
		// TODO: account_thresholds_updated
		// TODO: account_flags_updated
		// TODO: signer_added,signer_removed,signer_updated for master
		// TODO: signer_added,signer_removed,signer_updated for non-master
	case xdr.OperationTypeChangeTrust:
		// TODO: trustline_added,trustline_removed,trustline_updated
	case xdr.OperationTypeAllowTrust:
		// TODO: trustline_authorized,trustline_deauthorized
	case xdr.OperationTypeAccountMerge:
		// TODO: account_credited
		// TODO: account_debited
		// TODO: account_removed
	case xdr.OperationTypeInflation:
		// TODO: account_credited for each account that got inflation funds
	case xdr.OperationTypeManageData:
		// TODO: data_added,data_removed,data_updated
	default:
		is.Err = fmt.Errorf("Unknown operation type: %s", is.Cursor.OperationType())
	}
}

// ingestLedger ingests the current ledger
func (is *Session) ingestLedger() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Ledger(
		is.Cursor.LedgerID(),
		is.Cursor.Ledger(),
		is.Cursor.TransactionCount(),
		is.Cursor.LedgerOperationCount(),
	)

	// If this is ledger 1, create the root account
	if is.Cursor.LedgerSequence() == 1 {
		is.Ingestion.Account(1, keypair.Master(is.Network).Address())
	}

	for is.Cursor.NextTx() {
		is.ingestTransaction()
	}

	is.Ingested++

	return
}

func (is *Session) ingestOperation() {
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.Operation(
		is.Cursor.OperationID(),
		is.Cursor.TransactionID(),
		is.Cursor.OperationOrder(),
		is.Cursor.OperationSourceAccount(),
		is.Cursor.OperationType(),
		is.operationDetails(),
	)
	if is.Err != nil {
		return
	}

	// Import the new account if one was created
	if is.Cursor.Operation().Body.Type == xdr.OperationTypeCreateAccount {
		op := is.Cursor.Operation().Body.MustCreateAccountOp()
		is.Err = is.Ingestion.Account(is.Cursor.OperationID(), op.Destination.Address())
	}

	is.ingestOperationParticipants()
	is.ingestEffects()
}

func (is *Session) ingestOperationParticipants() {
	if is.Err != nil {
		return
	}

	// Find the participants
	var p []xdr.AccountId
	p, is.Err = participants.ForOperation(
		&is.Cursor.Transaction().Envelope.Tx,
		is.Cursor.Operation(),
	)
	if is.Err != nil {
		return
	}

	var aids []int64
	aids, is.Err = is.lookupParticipantIDs(p)
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.OperationParticipants(is.Cursor.OperationID(), aids)
	if is.Err != nil {
		return
	}
}

func (is *Session) ingestTransaction() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Transaction(
		is.Cursor.TransactionID(),
		is.Cursor.Transaction(),
		is.Cursor.TransactionFee(),
	)

	for is.Cursor.NextOp() {
		is.ingestOperation()
	}

	is.ingestTransactionParticipants()
}

func (is *Session) ingestTransactionParticipants() {
	if is.Err != nil {
		return
	}

	// Find the participants
	var p []xdr.AccountId
	p, is.Err = participants.ForTransaction(
		&is.Cursor.Transaction().Envelope.Tx,
		&is.Cursor.Transaction().ResultMeta,
		&is.Cursor.TransactionFee().Changes,
	)
	if is.Err != nil {
		return
	}

	var aids []int64
	aids, is.Err = is.lookupParticipantIDs(p)
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.TransactionParticipants(is.Cursor.TransactionID(), aids)
	if is.Err != nil {
		return
	}

}

func (is *Session) lookupParticipantIDs(aids []xdr.AccountId) (ret []int64, err error) {
	found := map[int64]bool{}

	for _, in := range aids {
		var out int64
		out, err = is.accountCache.Get(in.Address())
		if err != nil {
			return
		}

		// De-duplicate
		if _, ok := found[out]; ok {
			continue
		}

		found[out] = true
		ret = append(ret, out)
	}

	return
}

// operationDetails returns the details regarding the current operation, suitable
// for ingestion into a history_operation row
func (is *Session) operationDetails() map[string]interface{} {
	details := map[string]interface{}{}
	c := is.Cursor
	source := c.OperationSourceAccount()

	switch c.OperationType() {
	case xdr.OperationTypeCreateAccount:
		op := c.Operation().Body.MustCreateAccountOp()
		details["funder"] = source.Address()
		details["account"] = op.Destination.Address()
		details["starting_balance"] = amount.String(op.StartingBalance)
	case xdr.OperationTypePayment:
		op := c.Operation().Body.MustPaymentOp()
		details["from"] = source.Address()
		details["to"] = op.Destination.Address()
		details["amount"] = amount.String(op.Amount)
		c.assetDetails(details, op.Asset, "")
	case xdr.OperationTypePathPayment:
		op := c.Operation().Body.MustPathPaymentOp()
		details["from"] = source.Address()
		details["to"] = op.Destination.Address()

		result := c.OperationResult().MustTr().MustPathPaymentResult()

		details["amount"] = amount.String(op.DestAmount)
		details["source_amount"] = amount.String(result.SendAmount())
		details["source_max"] = amount.String(op.SendMax)
		c.assetDetails(details, op.DestAsset, "")
		c.assetDetails(details, op.SendAsset, "source_")

		var path = make([]map[string]interface{}, len(op.Path))
		for i := range op.Path {
			path[i] = make(map[string]interface{})
			c.assetDetails(path[i], op.Path[i], "")
		}
		details["path"] = path
	case xdr.OperationTypeManageOffer:
		op := c.Operation().Body.MustManageOfferOp()
		details["offer_id"] = op.OfferId
		details["amount"] = amount.String(op.Amount)
		details["price"] = op.Price.String()
		details["price_r"] = map[string]interface{}{
			"n": op.Price.N,
			"d": op.Price.D,
		}
		c.assetDetails(details, op.Buying, "buying_")
		c.assetDetails(details, op.Selling, "selling_")

	case xdr.OperationTypeCreatePassiveOffer:
		op := c.Operation().Body.MustCreatePassiveOfferOp()
		details["amount"] = amount.String(op.Amount)
		details["price"] = op.Price.String()
		details["price_r"] = map[string]interface{}{
			"n": op.Price.N,
			"d": op.Price.D,
		}
		c.assetDetails(details, op.Buying, "buying_")
		c.assetDetails(details, op.Selling, "selling_")
	case xdr.OperationTypeSetOptions:
		op := c.Operation().Body.MustSetOptionsOp()

		if op.InflationDest != nil {
			details["inflation_dest"] = op.InflationDest.Address()
		}

		if op.SetFlags != nil && *op.SetFlags > 0 {
			c.flagDetails(details, int32(*op.SetFlags), "set")
		}

		if op.ClearFlags != nil && *op.ClearFlags > 0 {
			c.flagDetails(details, int32(*op.ClearFlags), "clear")
		}

		if op.MasterWeight != nil {
			details["master_key_weight"] = *op.MasterWeight
		}

		if op.LowThreshold != nil {
			details["low_threshold"] = *op.LowThreshold
		}

		if op.MedThreshold != nil {
			details["med_threshold"] = *op.MedThreshold
		}

		if op.HighThreshold != nil {
			details["high_threshold"] = *op.HighThreshold
		}

		if op.HomeDomain != nil {
			details["home_domain"] = *op.HomeDomain
		}

		if op.Signer != nil {
			details["signer_key"] = op.Signer.PubKey.Address()
			details["signer_weight"] = op.Signer.Weight
		}
	case xdr.OperationTypeChangeTrust:
		op := c.Operation().Body.MustChangeTrustOp()
		c.assetDetails(details, op.Line, "")
		details["trustor"] = source.Address()
		details["trustee"] = details["asset_issuer"]
		details["limit"] = amount.String(op.Limit)
	case xdr.OperationTypeAllowTrust:
		op := c.Operation().Body.MustAllowTrustOp()
		c.assetDetails(details, op.Asset.ToAsset(source), "")
		details["trustee"] = source.Address()
		details["trustor"] = op.Trustor.Address()
		details["authorize"] = op.Authorize
	case xdr.OperationTypeAccountMerge:
		aid := c.Operation().Body.MustDestination()
		details["account"] = source.Address()
		details["into"] = aid.Address()
	case xdr.OperationTypeInflation:
		// no inflation details, presently
	case xdr.OperationTypeManageData:
		op := c.Operation().Body.MustManageDataOp()
		details["name"] = string(op.DataName)
		if op.DataValue != nil {
			details["value"] = base64.StdEncoding.EncodeToString(*op.DataValue)
		} else {
			details["value"] = nil
		}
	default:
		panic(fmt.Errorf("Unknown operation type: %s", c.OperationType()))
	}

	return details
}
