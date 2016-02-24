package core

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// Select implements the db.Query interface
func (q *TransactionByHash) Select(ctx context.Context, dest interface{}) error {
	sql := sq.Select("ctxh.*").
		From("txhistory ctxh").
		Limit(1).
		Where("ctxh.txid = ?", q.Hash)

	return q.DB.Select(ctx, sql, dest)
}

// Select implements the db.Query interface
func (q *TransactionByLedger) Select(ctx context.Context, dest interface{}) error {
	sql := sq.Select("ctxh.*").
		From("txhistory ctxh").
		OrderBy("ctxh.txindex ASC").
		Where("ctxh.ledgerseq = ?", q.Sequence)

	return q.DB.Select(ctx, sql, dest)
}
