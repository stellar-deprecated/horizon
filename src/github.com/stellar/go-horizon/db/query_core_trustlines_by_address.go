package db

import "golang.org/x/net/context"

type CoreTrustlinesByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreTrustlinesByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	sql := CoreTrustlineRecordSelect.Where("accountid = ?", q.Address)
	return q.SqlQuery.Select(ctx, sql, dest)
}
