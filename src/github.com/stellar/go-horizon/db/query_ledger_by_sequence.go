package db

import "golang.org/x/net/context"

type LedgerBySequenceQuery struct {
	SqlQuery
	Sequence int32
}

func (q LedgerBySequenceQuery) Select(ctx context.Context, dest interface{}) error {
	sql := LedgerRecordSelect.Where("sequence = ?", q.Sequence).Limit(1)

	return q.SqlQuery.Select(ctx, sql, dest)
}
