package db

import "golang.org/x/net/context"

type OperationByIdQuery struct {
	SqlQuery
	Id int64
}

func (q OperationByIdQuery) Get(ctx context.Context) ([]Record, error) {
	sql := OperationRecordSelect.Where("id = ?", q.Id).Limit(1)

	var records []OperationRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q OperationByIdQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
