package core

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// Select implements the db.Query interface
func (q *TransactionFeeByHash) Select(ctx context.Context, dest interface{}) error {
	sql := sq.Select("ctxfh.*").
		From("txfeehistory ctxfh").
		Limit(1).
		Where("ctxfh.txid = ?", q.Hash)

	return q.DB.Select(ctx, sql, dest)
}
