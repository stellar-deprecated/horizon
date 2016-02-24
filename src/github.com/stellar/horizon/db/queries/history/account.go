package history

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// Select implements the db.Query interface
func (q *AccountByID) Select(ctx context.Context, dest interface{}) error {
	sql := sq.
		Select("ha.*").
		From("history_accounts ha").
		Limit(1).
		Where("ha.id = ?", q.ID)

	return q.DB.Select(ctx, sql, dest)
}
