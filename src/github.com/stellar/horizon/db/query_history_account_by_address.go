package db

import "golang.org/x/net/context"

type HistoryAccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q HistoryAccountByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	sql := HistoryAccountRecordSelect.Where("address = ?", q.Address).Limit(1)
	return q.SqlQuery.Select(ctx, sql, dest)
}
