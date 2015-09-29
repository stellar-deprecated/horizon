package db

import "golang.org/x/net/context"

type TransactionByAddressAndSequence struct {
	SqlQuery
	Address  string
	Sequence uint64
}

func (q TransactionByAddressAndSequence) Select(ctx context.Context, dest interface{}) error {
	sql := TransactionRecordSelect.
		Limit(1).
		Where("ht.account = ?", q.Address).
		Where("ht.account_sequence = ?", q.Sequence)

	return q.SqlQuery.Select(ctx, sql, dest)
}
