package db

import "golang.org/x/net/context"

type OperationByIdQuery struct {
	SqlQuery
	Id int64
}

func (q OperationByIdQuery) Select(ctx context.Context, dest interface{}) error {
	sql := OperationRecordSelect.Where("hop.id = ?", q.Id).Limit(1)

	return q.SqlQuery.Select(ctx, sql, dest)
}
