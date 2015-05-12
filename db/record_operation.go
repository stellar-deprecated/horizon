package db

import (
	"fmt"
	sq "github.com/lann/squirrel"
	"github.com/lib/pq/hstore"
)

var OperationRecordSelect sq.SelectBuilder = sq.
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
