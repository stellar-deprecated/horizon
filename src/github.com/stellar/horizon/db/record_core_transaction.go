package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// CoreTransactionRecordSelect is a sql fragment to help select form queries that
// select into a CoreTransactionRecord
var CoreTransactionRecordSelect = sq.Select("ctxh.*").From("txhistory ctxh")

// CoreTransactionRecord is row of data from the `txhistory` table from stellar-core
type CoreTransactionRecord struct {
	TransactionHash string `db:"txid"`
	LedgerSequence  int32  `db:"ledgerseq"`
	Index           int32  `db:"txindex"`
	EnvelopeXDR     string `db:"txbody"`
	ResultXDR       string `db:"txresult"`
	ResultMetaXDR   string `db:"txmeta"`
}

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
