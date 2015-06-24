package db

import (
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
	HistoryRecord
	Address string `db:"address"`
}

