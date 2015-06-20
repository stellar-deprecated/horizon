package db

import "golang.org/x/net/context"

type LedgerPageQuery struct {
	SqlQuery
	PageQuery
}

func (q LedgerPageQuery) Select(ctx context.Context, dest interface{}) error {
	sql := LedgerRecordSelect.
		Limit(uint64(q.Limit))

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
