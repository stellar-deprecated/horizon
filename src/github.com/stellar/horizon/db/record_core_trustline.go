package db

import (
	sq "github.com/lann/squirrel"
)

var CoreTrustlineRecordSelect sq.SelectBuilder = sq.Select(
	"tl.accountid",
	"tl.assettype",
	"tl.issuer",
	"tl.assetcode",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")
