package db

import (
	"database/sql"
	sq "github.com/lann/squirrel"
	"time"
)

// Provides a squirrel.SelectBuilder upon which you may build actual queries.
var TransactionRecordSelect sq.SelectBuilder = sq.
	Select("ht.*").
	From("history_transactions ht")

type TransactionRecord struct {
	HistoryRecord
	TransactionHash     string    `db:"transaction_hash"`
	LedgerSequence      int32     `db:"ledger_sequence"`
	ApplicationOrder    int32     `db:"application_order"`
	Account             string    `db:"account"`
	AccountSequence     int64     `db:"account_sequence"`
	MaxFee              int32     `db:"max_fee"`
	FeePaid             int32     `db:"fee_paid"`
	OperationCount      int32     `db:"operation_count"`
	TxResult            sql.NullString  `db:"txresult"`
	Success             sql.NullBool    `db:"success"`
	TransactionStatusId int32     `db:"transaction_status_id"`
	CreatedAt           time.Time `db:"created_at"`
	UpdatedAt           time.Time `db:"updated_at"`
}

func (r TransactionRecord) TableName() string {
	return "history_transactions"
}
