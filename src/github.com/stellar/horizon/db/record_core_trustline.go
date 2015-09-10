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

// A row of data from the `trustlines` table from stellar-core
type CoreTrustlineRecord struct {
	Accountid string
	Assettype int32
	Issuer    string
	Assetcode string
	Tlimit    int64
	Balance   int64
	Flags     int32
}
