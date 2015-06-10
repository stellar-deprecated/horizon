package db

import (
	"fmt"

	"github.com/jmoiron/sqlx/types"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
)

var OperationRecordSelect sq.SelectBuilder = sq.
	Select("hop.*").
	From("history_operations hop")

type OperationRecord struct {
	Id               int64             `db:"id"`
	TransactionId    int64             `db:"transaction_id"`
	ApplicationOrder int32             `db:"application_order"`
	Type             xdr.OperationType `db:"type"`
	DetailsString    types.JsonText    `db:"details"`
}

func (r OperationRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}

func (r OperationRecord) Details() (result map[string]interface{}, err error) {
	err = r.DetailsString.Unmarshal(&result)
	return
}
