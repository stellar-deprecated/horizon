package db

// NOTE: this file is a temporary home for the SelectBuilders associated with
// querying the core database.

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

var CoreAccountRecordSelect sq.SelectBuilder = sq.Select(
	"a.accountid",
	"a.balance",
	"a.seqnum",
	"a.numsubentries",
	"a.inflationdest",
	"a.homedomain",
	"a.thresholds",
	"a.flags",
).From("accounts a")

var CoreLedgerHeaderRecordSelect = sq.Select(
	"clh.*",
).From("ledgerheaders clh")

var CoreOfferRecordSelect = sq.Select("co.*").From("offers co")

var CoreSignerRecordSelect sq.SelectBuilder = sq.Select(
	"si.accountid",
	"si.publickey",
	"si.weight",
).From("signers si")

// CoreTransactionRecordSelect is a sql fragment to help select form queries that
// select into a CoreTransactionRecord
var CoreTransactionRecordSelect = sq.Select("ctxh.*").From("txhistory ctxh")

var CoreTrustlineRecordSelect sq.SelectBuilder = sq.Select(
	"tl.accountid",
	"tl.assettype",
	"tl.issuer",
	"tl.assetcode",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")

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
