package db

import (
	"database/sql"
	"fmt"
	"github.com/lann/squirrel"
	"time"
)

// Provides a squirrel.SelectBuilder upon which you may build actual queries.
var TransactionRecordSelect squirrel.SelectBuilder = squirrel.Select(
	"ht.id",
	"ht.transaction_hash",
	"ht.ledger_sequence",
	"ht.application_order",
	"ht.account",
	"ht.account_sequence",
	"ht.max_fee",
	"ht.fee_paid",
	"ht.operation_count",
).From("history_transactions ht")

type TransactionRecord struct {
	Id               int64
	TransactionHash  string
	LedgerSequence   int32
	ApplicationOrder int32
	Account          string
	AccountSequence  int64
	MaxFee           int32
	FeePaid          int32
	OperationCount   int32
	ClosedAt         time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

func (r TransactionRecord) TableName() string {
	return "history_transactions"
}

func (r TransactionRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}

func (r *TransactionRecord) ScanFrom(rows *sql.Rows) error {
	return rows.Scan(
		&r.Id,
		&r.TransactionHash,
		&r.LedgerSequence,
		&r.ApplicationOrder,
		&r.Account,
		&r.AccountSequence,
		&r.MaxFee,
		&r.FeePaid,
		&r.OperationCount,
	)
}
