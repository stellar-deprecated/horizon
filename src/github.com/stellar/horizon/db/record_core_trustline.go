package db

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
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
	Assettype xdr.AssetType
	Issuer    string
	Assetcode string
	Tlimit    xdr.Int64
	Balance   xdr.Int64
	Flags     int32
}
