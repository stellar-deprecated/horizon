package db

import (
	"database/sql"
	"fmt"
	"github.com/lann/squirrel"
	"github.com/lib/pq/hstore"
)

var OperationRecordSelect squirrel.SelectBuilder = squirrel.Select(
	"hop.id",
	"hop.transaction_id",
	"hop.application_order",
	"hop.type",
	"hop.details",
).From("history_operations hop")

type OperationRecord struct {
	Id               int64
	TransactionId    int64
	ApplicationOrder int32
	Type             int32
	Details          hstore.Hstore
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
