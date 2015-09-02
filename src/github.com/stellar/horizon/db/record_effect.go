package db

import (
	"database/sql"
	"encoding/json"
	"fmt"
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
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

// SQLFilter implementerations

// EffectTypeFilter represents a filter that excludes all rows that do not match the
// type specified by the filter
type EffectTypeFilter struct {
	Type int32
}

func (f *EffectTypeFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	return sql.Where("heff.type = ?", f.Type), nil
}

// EffectAccountFilter represents a filter that excludes all rows that do not apply to
// the account specified
type EffectAccountFilter struct {
	SqlQuery
	AccountAddress string
}

func (f *EffectAccountFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	var account HistoryAccountRecord
	err := Get(ctx, HistoryAccountByAddressQuery{f.SqlQuery, f.AccountAddress}, &account)

	if err != nil {
		return sql, err
	}

	return sql.Where("heff.history_account_id = ?", account.Id), nil
}

// EffectLedgerFilter represents a filter that excludes all rows that did not occur
// in the specified ledger
type EffectLedgerFilter struct {
	LedgerSequence int32
}

func (f *EffectLedgerFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	start := TotalOrderId{LedgerSequence: f.LedgerSequence}
	end := TotalOrderId{LedgerSequence: f.LedgerSequence + 1}
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}

// EffectTransactionFilter represents a filter that excludes all rows that did not occur
// in the specified transaction
type EffectTransactionFilter struct {
	SqlQuery
	TransactionHash string
}

func (f *EffectTransactionFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	var tx TransactionRecord
	err := Get(ctx, TransactionByHashQuery{f.SqlQuery, f.TransactionHash}, &tx)

	if err != nil {
		return sql, nil
	}

	start := ParseTotalOrderId(tx.Id)
	end := start
	end.TransactionOrder++
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}

// EffectOperationFilter represents a filter that excludes all rows that did not occur
// in the specified operation
type EffectOperationFilter struct {
	OperationID int64
}

func (f *EffectOperationFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	start := ParseTotalOrderId(f.OperationID)
	end := start
	end.OperationOrder++
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}
