package db

import "golang.org/x/net/context"

type LedgerPageQuery struct {
	SqlQuery
	PageQuery
}

func (q LedgerPageQuery) Get(ctx context.Context) ([]Record, error) {
	sql := LedgerRecordSelect.
		Limit(uint64(q.Limit))

	switch q.Order {
	case "asc":
		sql = sql.Where("hl.id > ?", q.Cursor).OrderBy("hl.id asc")
	case "desc":
		sql = sql.Where("hl.id < ?", q.Cursor).OrderBy("hl.id desc")
	}

	var records []LedgerRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q LedgerPageQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
