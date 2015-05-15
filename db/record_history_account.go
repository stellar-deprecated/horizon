package db

import (
	"fmt"

	sq "github.com/lann/squirrel"
)

// HistoryAccountRecordSelect is a reusable select builder to make it easier
// to query upon the history_accounts table
var HistoryAccountRecordSelect = sq.
	Select("ha.*").
	From("history_accounts ha")

// HistoryAccountRecord represents a single row from the history database's
// `history_accounts` table
type HistoryAccountRecord struct {
	Id      int64  `db:"id"`
	Address string `db:"address"`
}

// PagingToken provides the paging token for this account, for use
// in the horizon paging system
func (r HistoryAccountRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
