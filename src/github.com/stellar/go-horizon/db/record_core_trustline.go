package db

import (
	sq "github.com/lann/squirrel"
)

var CoreTrustlineRecordSelect sq.SelectBuilder = sq.Select(
	"tl.accountid",
	"tl.issuer",
	"tl.alphanumcurrency",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")

// A row of data from the `accounts` table from stellar-core
type CoreTrustlineRecord struct {
	Accountid        string
	Issuer           string
	Alphanumcurrency string
	Tlimit           int64
	Balance          int64
	Flags            int32
}
