package ingest

import (
	"encoding/json"
	"fmt"
	"time"

	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/sqx"
)

type ingestionBuffer struct {
	IB       sq.InsertBuilder
	count    int
	buffered sq.InsertBuilder
}

// Account ingests the provided account data into a new row in the
// `history_accounts` table
func (ingest *Ingestion) Account(id int64, address string) error {
	ingest.accounts.Add(id, address)

	return nil
}

// Clear removes data from the ledger
func (ingest *Ingestion) Clear(start int64, end int64) error {

	if start <= 1 {
		del := ingest.tx.Delete("history_accounts").Where("id = 1")
		ingest.tx.Exec(del)
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
	return ingest.flush()
}

// Flush writes the currently buffered rows to the db, and if successful
// starts a new transaction.
func (ingest *Ingestion) Flush() error {
	err := ingest.flush()
	if err != nil {
		return err
	}

	return ingest.Start()
}

// Ledger adds a ledger to the current ingestion
func (ingest *Ingestion) Ledger(c *Cursor) error {
	header := c.Ledger()
	ingest.ledgers.Add(
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

	ingest.operations.Add(
		c.OperationID(),
		c.TransactionID(),
		c.OperationOrder(),
		c.OperationSourceAddress(),
		c.OperationType(),
		djson,
	)
	return nil
}

// Rollback aborts this ingestions transaction
func (ingest *Ingestion) Rollback() (err error) {
	if ingest.tx == nil {
		panic("Ingestion hasn't started: cannot rollback")
	}

	err = ingest.tx.Rollback()
	ingest.tx = nil
	return
}

// Start makes the ingestion reeady, initializing the insert builders and tx
func (ingest *Ingestion) Start() (err error) {
	if ingest.tx != nil {
		panic("Ingestion already started")
	}

	ingest.tx, err = db.Begin(ingest.Ingester.HorizonDB)
	if err != nil {
		return
	}

	ingest.createInsertBuilders()

	return
}

// Transaction ingests the provided transaction data into a new row in the
// `history_transactions` table
func (ingest *Ingestion) Transaction(c *Cursor) {
	tx, fee := c.TransactionAndFee()

	ingest.transactions.Add(
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
}

func (ingest *Ingestion) clearRange(start int64, end int64, table string, idCol string) error {
	del := ingest.tx.Delete(table).Where(
		fmt.Sprintf("%s >= ? AND %s < ?", idCol, idCol),
		start,
		end,
	)
	_, err := ingest.tx.Exec(del)
	return err
}

func (ingest *Ingestion) createInsertBuilders() {
	ingest.ledgers = ingestionBuffer{
		IB: sq.Insert("history_ledgers").Columns(
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
		),
	}

	ingest.accounts = ingestionBuffer{
		IB: sq.Insert("history_accounts").Columns(
			"id",
			"address",
		),
	}

	ingest.transactions = ingestionBuffer{
		IB: sq.Insert("history_transactions").Columns(
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
		),
	}

	ingest.operations = ingestionBuffer{
		IB: sq.Insert("history_operations").Columns(
			"id",
			"transaction_id",
			"application_order",
			"source_account",
			"type",
			"details",
		),
	}

	ingest.effects = ingestionBuffer{
		IB: sq.Insert("history_effects").Columns(
			"TODO",
		),
	}
}

func (ingest *Ingestion) flush() error {
	err := ingest.ledgers.Flush(ingest.tx)
	if err != nil {
		return err
	}

	err = ingest.accounts.Flush(ingest.tx)
	if err != nil {
		return err
	}

	err = ingest.transactions.Flush(ingest.tx)
	if err != nil {
		return err
	}

	err = ingest.operations.Flush(ingest.tx)
	if err != nil {
		return err
	}

	err = ingest.effects.Flush(ingest.tx)
	if err != nil {
		return err
	}

	err = ingest.tx.Commit()
	if err != nil {
		return err
	}

	ingest.tx = nil
	return nil
}

func (ingest *Ingestion) formatTimeBounds(bounds *xdr.TimeBounds) interface{} {
	if bounds == nil {
		return nil
	}

	return sq.Expr("?::int8range", fmt.Sprintf("[%d,%d]", bounds.MinTime, bounds.MaxTime))
}

func (buf *ingestionBuffer) Add(args ...interface{}) {
	base := buf.buffered
	if buf.count == 0 {
		base = buf.IB
	}

	buf.buffered = base.Values(args...)
	buf.count++
}

func (buf *ingestionBuffer) Flush(tx *db.Tx) error {
	if buf.count == 0 {
		return nil
	}

	_, err := tx.Exec(buf.buffered)
	if err != nil {
		return err
	}

	buf.count = 0
	return nil
}
