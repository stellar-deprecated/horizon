package db

import (
	"database/sql"
	"encoding/json"
	"fmt"

	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
)

var OperationRecordSelect sq.SelectBuilder = sq.
	Select("hop.*").
	From("history_operations hop")

type OperationRecord struct {
    RecordBase
	TransactionId    int64             `db:"transaction_id"`
	ApplicationOrder int32             `db:"application_order"`
	Type             xdr.OperationType `db:"type"`
	DetailsString    sql.NullString    `db:"details"`
}

func (r OperationRecord) Details() (result map[string]interface{}, err error) {
	if !r.DetailsString.Valid {
		return
	}

	err = json.Unmarshal([]byte(r.DetailsString.String), &result)

	return
}
