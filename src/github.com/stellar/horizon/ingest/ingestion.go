package ingest

import (
	"encoding/json"
	"fmt"
	"time"

	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db/sqx"
)

type effectFactory struct {
	opid int64
	idx  int
	dest *Ingestion
}

// Account ingests the provided account data into a new row in the
// `history_accounts` table
func (ingest *Ingestion) Account(id int64, address string) error {
	sql := ingest.accounts.Values(id, address)

	_, err := ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

// Clear removes data from the ledger
func (ingest *Ingestion) Clear(start int64, end int64) error {

	if start <= 1 {
		del := sq.Delete("history_accounts").Where("id = 1")
		ingest.DB.Exec(del)
	}

	err := ingest.clearRange(start, end, "history_effects", "history_operation_id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_operation_participants", "history_operation_id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_operations", "id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_transaction_participants", "history_transaction_id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_transactions", "id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_accounts", "id")
	if err != nil {
		return err
	}
	err = ingest.clearRange(start, end, "history_ledgers", "id")
	if err != nil {
		return err
	}

	return nil
}

// Close finishes the current transaction and finishes this ingestion.
func (ingest *Ingestion) Close() error {
	return ingest.commit()
}

// Effect adds a new row into the `history_effects` table.
func (ingest *Ingestion) Effect(aid int64, opid int64, order int, typ string, details interface{}) error {
	djson, err := json.Marshal(details)
	if err != nil {
		return err
	}

	sql := ingest.effects.Values(aid, opid, order, typ, djson)

	_, err = ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

// Flush writes the currently buffered rows to the db, and if successful
// starts a new transaction.
func (ingest *Ingestion) Flush() error {
	err := ingest.commit()
	if err != nil {
		return err
	}

	return ingest.Start()
}

// Ledger adds a ledger to the current ingestion
func (ingest *Ingestion) Ledger(c *Cursor) error {
	header := c.Ledger()
	sql := ingest.ledgers.Values(
		CurrentVersion,
		c.LedgerID(),
		c.LedgerSequence(),
		header.LedgerHash,
		header.PrevHash,
		header.Data.TotalCoins,
		header.Data.FeePool,
		header.Data.BaseFee,
		header.Data.BaseReserve,
		header.Data.MaxTxSetSize,
		time.Unix(header.CloseTime, 0).UTC(),
		time.Now().UTC(),
		time.Now().UTC(),
		c.TransactionCount(),
		c.LedgerOperationCount(),
	)

	_, err := ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

// Operation ingests the provided operation data into a new row in the
// `history_operations` table
func (ingest *Ingestion) Operation(c *Cursor) error {
	dets := c.OperationDetails()
	djson, err := json.Marshal(dets)
	if err != nil {
		return err
	}

	sql := ingest.operations.Values(
		c.OperationID(),
		c.TransactionID(),
		c.OperationOrder(),
		c.OperationSourceAddress(),
		c.OperationType(),
		djson,
	)
	_, err = ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

// OperationParticipants ingests the provided accounts `aids` as participants of
// operation with id `op`, creating a new row in the
// `history_operation_participants` table.
func (ingest *Ingestion) OperationParticipants(op int64, aids []int64) error {
	sql := ingest.operation_participants

	for _, aid := range aids {
		sql = sql.Values(op, aid)
	}

	_, err := ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

// Rollback aborts this ingestions transaction
func (ingest *Ingestion) Rollback() (err error) {
	err = ingest.DB.Rollback()
	return
}

// Start makes the ingestion reeady, initializing the insert builders and tx
func (ingest *Ingestion) Start() (err error) {
	err = ingest.DB.Begin()
	if err != nil {
		return
	}

	ingest.createInsertBuilders()

	return
}

// Transaction ingests the provided transaction data into a new row in the
// `history_transactions` table
func (ingest *Ingestion) Transaction(c *Cursor) error {
	tx, fee := c.TransactionAndFee()

	sql := ingest.transactions.Values(
		c.TransactionID(),
		tx.TransactionHash,
		tx.LedgerSequence,
		tx.Index,
		tx.SourceAddress(),
		tx.Sequence(),
		tx.Fee(),
		c.OperationCount(),
		tx.EnvelopeXDR(),
		tx.ResultXDR(),
		tx.ResultMetaXDR(),
		fee.ChangesXDR(),
		sqx.StringArray(tx.Base64Signatures()),
		ingest.formatTimeBounds(tx.Envelope.Tx.TimeBounds),
		tx.MemoType(),
		tx.Memo(),
		time.Now().UTC(),
		time.Now().UTC(),
	)

	_, err := ingest.DB.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

func (ingest *Ingestion) clearRange(start int64, end int64, table string, idCol string) error {
	del := sq.Delete(table).Where(
		fmt.Sprintf("%s >= ? AND %s < ?", idCol, idCol),
		start,
		end,
	)
	_, err := ingest.DB.Exec(del)
	return err
}

func (ingest *Ingestion) createInsertBuilders() {
	ingest.ledgers = sq.Insert("history_ledgers").Columns(
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
		"transaction_count",
		"operation_count",
	)

	ingest.accounts = sq.Insert("history_accounts").Columns(
		"id",
		"address",
	)

	ingest.transactions = sq.Insert("history_transactions").Columns(
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
	)

	ingest.transaction_participants = sq.Insert("history_transaction_participants").Columns(
		"history_transaction_id",
		"history_account_id",
	)

	ingest.operations = sq.Insert("history_operations").Columns(
		"id",
		"transaction_id",
		"application_order",
		"source_account",
		"type",
		"details",
	)

	ingest.operation_participants = sq.Insert("history_operation_participants").Columns(
		"history_operation_id",
		"history_account_id",
	)

	ingest.effects = sq.Insert("history_effects").Columns(
		"history_account_id",
		"history_operation_id",
		"order",
		"type",
		"details",
	)
}

func (ingest *Ingestion) commit() error {
	err := ingest.DB.Commit()
	if err != nil {
		return err
	}

	return nil
}

func (ingest *Ingestion) formatTimeBounds(bounds *xdr.TimeBounds) interface{} {
	if bounds == nil {
		return nil
	}

	return sq.Expr("?::int8range", fmt.Sprintf("[%d,%d]", bounds.MinTime, bounds.MaxTime))
}
