package db

import (
	"fmt"
	sq "github.com/lann/squirrel"
)

var AccountRecordSelect sq.SelectBuilder = sq.
	Select("ha.*").
	From("history_accounts ha")

type AccountRecord struct {
	Id      int64  `db:"id"`
	Address string `db:"address"`
}

func (r AccountRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
