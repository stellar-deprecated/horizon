package db

import "golang.org/x/net/context"

type LedgerPageQuery struct {
	SqlQuery
	PageQuery
}

func (q LedgerPageQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := LedgerRecordSelect.
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return nil, err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("hl.id > ?", cursor).OrderBy("hl.id asc")
	case "desc":
		sql = sql.Where("hl.id < ?", cursor).OrderBy("hl.id desc")
	}

	var records []LedgerRecord
	err = q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q LedgerPageQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
