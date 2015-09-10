package db

import "golang.org/x/net/context"

type CoreSignersByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreSignersByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	sql := CoreSignerRecordSelect.Where("accountid = ?", q.Address)
	return q.SqlQuery.Select(ctx, sql, dest)
}
