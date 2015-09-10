package db

import (
	"database/sql"
	"encoding/json"
	"fmt"
	sq "github.com/lann/squirrel"
)

var EffectRecordSelect sq.SelectBuilder = sq.
	Select("heff.*, hacc.address").
	From("history_effects heff").
	LeftJoin("history_accounts hacc ON hacc.id = heff.history_account_id")

type EffectRecord struct {
	HistoryAccountID   int64          `db:"history_account_id"`
	Account            string         `db:"address"`
	HistoryOperationID int64          `db:"history_operation_id"`
	Order              int32          `db:"order"`
	Type               int32          `db:"type"`
	DetailsString      sql.NullString `db:"details"`
}

func (r EffectRecord) Details() (result map[string]interface{}, err error) {
	if !r.DetailsString.Valid {
		return
	}

	err = json.Unmarshal([]byte(r.DetailsString.String), &result)

	return
}

// ID returns a lexically ordered id for this effect record
func (r EffectRecord) ID() string {
	return fmt.Sprintf("%019d-%010d", r.HistoryOperationID, r.Order)
}

func (r EffectRecord) PagingToken() string {
	return fmt.Sprintf("%d-%d", r.HistoryOperationID, r.Order)
}
