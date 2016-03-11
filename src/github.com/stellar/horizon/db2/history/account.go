package history

import (
	sq "github.com/lann/squirrel"
)

// AccountByID loads a row from `history_accounts`, by id
func (q *Q) AccountByID(dest interface{}, id int64) error {
	sql := sq.
		Select("ha.*").
		From("history_accounts ha").
		Limit(1).
		Where("ha.id = ?", id)

	return q.Get(dest, sql)
}
