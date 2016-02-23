package db

// NOTE: this file is a temporary home for the SelectBuilders associated with
// querying the core database.

import (
	sq "github.com/lann/squirrel"
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

var CoreTrustlineRecordSelect sq.SelectBuilder = sq.Select(
	"tl.accountid",
	"tl.assettype",
	"tl.issuer",
	"tl.assetcode",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")
