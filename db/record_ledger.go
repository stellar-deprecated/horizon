package db

import (
	"database/sql"
	"fmt"
	sq "github.com/lann/squirrel"
	"time"
)

var LedgerRecordSelect sq.SelectBuilder = sq.
	Select("hl.*").
	From("history_ledgers hl")

type LedgerRecord struct {
	Id                 int64          `db:"id"`
	Sequence           int32          `db:"sequence"`
	LedgerHash         string         `db:"ledger_hash"`
	PreviousLedgerHash sql.NullString `db:"previous_ledger_hash"`
	TransactionCount   int32          `db:"transaction_count"`
	OperationCount     int32          `db:"operation_count"`
	ClosedAt           time.Time      `db:"closed_at"`
	CreatedAt          time.Time      `db:"created_at"`
	UpdatedAt          time.Time      `db:"updated_at"`
}

func (r LedgerRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
