package db

import (
	sq "github.com/lann/squirrel"
)

var HistoryAccountRecordSelect sq.SelectBuilder = sq.
	Select("ha.*").
	From("history_accounts ha")

type HistoryAccountRecord struct {
	Id      int64  `db:"id"`
	Address string `db:"address"`
}
