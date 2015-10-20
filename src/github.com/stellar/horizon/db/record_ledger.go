package db

import (
	"database/sql"
	sq "github.com/lann/squirrel"
	"time"
)

var LedgerRecordSelect sq.SelectBuilder = sq.Select(
	"hl.id",
	"hl.sequence",
	"hl.importer_version",
	"hl.ledger_hash",
	"hl.previous_ledger_hash",
	"hl.transaction_count",
	"hl.operation_count",
	"hl.closed_at",
	"hl.created_at",
	"hl.updated_at",
	"hl.total_coins",
	"hl.fee_pool",
	"hl.base_fee",
	"hl.base_reserve",
	"hl.max_tx_set_size",
).From("history_ledgers hl")

type LedgerRecord struct {
	HistoryRecord
	Sequence           int32          `db:"sequence"`
	ImporterVersion    int32          `db:"importer_version"`
	LedgerHash         string         `db:"ledger_hash"`
	PreviousLedgerHash sql.NullString `db:"previous_ledger_hash"`
	TransactionCount   int32          `db:"transaction_count"`
	OperationCount     int32          `db:"operation_count"`
	ClosedAt           time.Time      `db:"closed_at"`
	CreatedAt          time.Time      `db:"created_at"`
	UpdatedAt          time.Time      `db:"updated_at"`
	TotalCoins         int64          `db:"total_coins"`
	FeePool            int64          `db:"fee_pool"`
	BaseFee            int32          `db:"base_fee"`
	BaseReserve        int32          `db:"base_reserve"`
	MaxTxSetSize       int32          `db:"max_tx_set_size"`
}
