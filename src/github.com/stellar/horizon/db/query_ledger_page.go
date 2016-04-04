package db

import (
	"github.com/stellar/horizon/db2"
	"golang.org/x/net/context"
)

type LedgerPageQuery struct {
	SqlQuery
	db2.PageQuery
}

func (q LedgerPageQuery) Select(ctx context.Context, dest interface{}) error {
	sql := LedgerRecordSelect.
		Limit(q.Limit)

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("hl.id > ?", cursor).OrderBy("hl.id asc")
	case "desc":
		sql = sql.Where("hl.id < ?", cursor).OrderBy("hl.id desc")
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
