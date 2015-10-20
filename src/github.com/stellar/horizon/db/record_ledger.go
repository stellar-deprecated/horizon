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
}
