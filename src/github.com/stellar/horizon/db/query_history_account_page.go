package db

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/db2"
	"golang.org/x/net/context"
)

// HistoryAccountPageQuery queries for a single page of HitoryAccount objects,
// in the normal collection paging style
type HistoryAccountPageQuery struct {
	SqlQuery
	db2.PageQuery
}

// Get executes the query, returning any results
func (q HistoryAccountPageQuery) Select(ctx context.Context, dest interface{}) error {
	sql := sq.
		Select("ha.*").
		From("history_accounts ha").
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("ha.id > ?", cursor).OrderBy("ha.id asc")
	case "desc":
		sql = sql.Where("ha.id < ?", cursor).OrderBy("ha.id desc")
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
