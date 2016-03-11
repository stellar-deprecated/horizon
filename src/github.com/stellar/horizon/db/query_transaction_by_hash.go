package db

import "golang.org/x/net/context"

// TransactionByHashQuery is deprecated, please use `*history.Q` instead.
type TransactionByHashQuery struct {
	SqlQuery
	Hash string
}

// Select implements db.SqlQuery
func (q TransactionByHashQuery) Select(ctx context.Context, dest interface{}) error {
	sql := TransactionRecordSelect.
		Limit(1).
		Where("ht.transaction_hash = ?", q.Hash)

	return q.SqlQuery.Select(ctx, sql, dest)
}
