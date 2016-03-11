package history

import (
	sq "github.com/lann/squirrel"
)

// AccountByAddress loads a row from `history_accounts`, by address
func (q *Q) AccountByAddress(dest interface{}, addy string) error {
	sql := sq.
		Select("ha.*").
		From("history_accounts ha").
		Limit(1).
		Where("ha.address = ?", addy)

	return q.Get(dest, sql)
}

// AccountByID loads a row from `history_accounts`, by id
func (q *Q) AccountByID(dest interface{}, id int64) error {
	sql := sq.
		Select("ha.*").
		From("history_accounts ha").
		Limit(1).
		Where("ha.id = ?", id)

	return q.Get(dest, sql)
}
