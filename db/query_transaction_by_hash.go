package db

import "golang.org/x/net/context"

type TransactionByHashQuery struct {
	SqlQuery
	Hash string
}

func (q TransactionByHashQuery) Select(ctx context.Context, dest interface{}) error {
	sql := TransactionRecordSelect.
		Limit(1).
		Where("transaction_hash = ?", q.Hash)

	return q.SqlQuery.Select(ctx, sql, dest)
}
