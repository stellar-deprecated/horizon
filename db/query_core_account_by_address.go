package db

import "golang.org/x/net/context"

type CoreAccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreAccountByAddressQuery) Get(ctx context.Context) ([]Record, error) {
	sql := CoreAccountRecordSelect.Where("accountid = ?", q.Address).Limit(1)

	var records []CoreAccountRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q CoreAccountByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
