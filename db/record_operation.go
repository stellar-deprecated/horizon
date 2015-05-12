package db

import (
	"database/sql"
	"fmt"
	"github.com/lann/squirrel"
	"github.com/lib/pq/hstore"
)

var OperationRecordSelect squirrel.SelectBuilder = squirrel.
	Select("hop.*").
	From("history_operations hop")

type OperationRecord struct {
	Id               int64         `db:"id"`
	TransactionId    int64         `db:"transaction_id"`
	ApplicationOrder int32         `db:"application_order"`
	Type             int32         `db:"type"`
	Details          hstore.Hstore `db:"details"`
}

func (r OperationRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}

func (r *OperationRecord) ScanFrom(rows *sql.Rows) error {
	return rows.Scan(
		&r.Id,
		&r.TransactionId,
		&r.ApplicationOrder,
		&r.Type,
		&r.Details,
	)
}
