package db

import "golang.org/x/net/context"

type HistoryAccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q HistoryAccountByAddressQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := HistoryAccountRecordSelect.Where("address = ?", q.Address).Limit(1)

	var records []HistoryAccountRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q HistoryAccountByAddressQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
