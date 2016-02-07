package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// CoreTransactionRecordSelect is a sql fragment to help select form queries that
// select into a CoreTransactionRecord
var CoreTransactionRecordSelect = sq.Select("ctxh.*").From("txhistory ctxh")

// txhistory queries

type CoreTransactionByHashQuery struct {
	SqlQuery
	Hash string
}

func (q CoreTransactionByHashQuery) Select(ctx context.Context, dest interface{}) error {
	sql := CoreTransactionRecordSelect.
		Limit(1).
		Where("ctxh.txid = ?", q.Hash)

	return q.SqlQuery.Select(ctx, sql, dest)
}
