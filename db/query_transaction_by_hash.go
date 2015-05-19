package db

import "golang.org/x/net/context"

type TransactionByHashQuery struct {
	SqlQuery
	Hash string
}

func (q TransactionByHashQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := TransactionRecordSelect.
		Limit(1).
		Where("transaction_hash = ?", q.Hash)

	var records []TransactionRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q TransactionByHashQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
