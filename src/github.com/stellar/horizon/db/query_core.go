package db

// NOTE: this file is a temporary home for the SelectBuilders associated with
// querying the core database.

import (
	sq "github.com/lann/squirrel"
)

var CoreOfferRecordSelect = sq.Select("co.*").From("offers co")

var CoreTrustlineRecordSelect sq.SelectBuilder = sq.Select(
	"tl.accountid",
	"tl.assettype",
	"tl.issuer",
	"tl.assetcode",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")
