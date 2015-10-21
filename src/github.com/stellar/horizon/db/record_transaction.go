package db

import (
	"database/sql"
	sq "github.com/lann/squirrel"
	"time"
)

// Provides a squirrel.SelectBuilder upon which you may build actual queries.
var TransactionRecordSelect sq.SelectBuilder = sq.
	Select(
	"ht.id, " +
		"ht.transaction_hash, " +
		"ht.ledger_sequence, " +
		"ht.application_order, " +
		"ht.account, " +
		"ht.account_sequence, " +
		"ht.fee_paid, " +
		"ht.operation_count, " +
		"ht.tx_envelope, " +
		"ht.tx_result, " +
		"ht.tx_meta, " +
		"ht.tx_fee_meta, " +
		"ht.created_at, " +
		"ht.updated_at, " +
		"array_to_string(ht.signatures, ',') AS signatures, " +
		"ht.memo_type, " +
		"ht.memo, " +
		"lower(ht.time_bounds) AS valid_after, " +
		"upper(ht.time_bounds) AS valid_before, " +
		"hl.closed_at AS ledger_close_time").
	From("history_transactions ht").
	LeftJoin("history_ledgers hl ON ht.ledger_sequence = hl.sequence")

type TransactionRecord struct {
	HistoryRecord
	TransactionHash  string         `db:"transaction_hash"`
	LedgerSequence   int32          `db:"ledger_sequence"`
	LedgerCloseTime  time.Time      `db:"ledger_close_time"`
	ApplicationOrder int32          `db:"application_order"`
	Account          string         `db:"account"`
	AccountSequence  int64          `db:"account_sequence"`
	FeePaid          int32          `db:"fee_paid"`
	OperationCount   int32          `db:"operation_count"`
	TxEnvelope       string         `db:"tx_envelope"`
	TxResult         string         `db:"tx_result"`
	TxMeta           string         `db:"tx_meta"`
	TxFeeMeta        string         `db:"tx_fee_meta"`
	SignatureString  string         `db:"signatures"`
	MemoType         string         `db:"memo_type"`
	Memo             sql.NullString `db:"memo"`
	ValidAfter       sql.NullInt64  `db:"valid_after"`
	ValidBefore      sql.NullInt64  `db:"valid_before"`
	CreatedAt        time.Time      `db:"created_at"`
	UpdatedAt        time.Time      `db:"updated_at"`
}

func (r TransactionRecord) TableName() string {
	return "history_transactions"
}
