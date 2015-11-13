package db

import (
	"database/sql"
	"encoding/json"
	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
)

var OperationRecordSelect sq.SelectBuilder = sq.
	Select(
	"hop.id, " +
		"hop.transaction_id, " +
		"hop.application_order, " +
		"hop.type, " +
		"hop.details, " +
		"hop.source_account, " +
		"ht.transaction_hash").
	From("history_operations hop").
	LeftJoin("history_transactions ht ON ht.id = hop.transaction_id")

type OperationRecord struct {
	HistoryRecord
	TransactionId    int64             `db:"transaction_id"`
	TransactionHash  string            `db:"transaction_hash"`
	ApplicationOrder int32             `db:"application_order"`
	Type             xdr.OperationType `db:"type"`
	DetailsString    sql.NullString    `db:"details"`
	SourceAccount    string            `db:"source_account"`
}

func (r OperationRecord) UnmarshalDetails(dest interface{}) error {
	if !r.DetailsString.Valid {
		return nil
	}

	err := json.Unmarshal([]byte(r.DetailsString.String), &dest)
	if err != nil {
		err = errors.Wrap(err, 1)
	}

	return err
}
