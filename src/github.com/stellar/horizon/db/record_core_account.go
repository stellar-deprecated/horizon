package db

import (
	"github.com/guregu/null"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
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

const (
	FlagAuthRequired  = 1 << iota
	FlagAuthRevocable = 1 << iota
)

// A row of data from the `accounts` table from stellar-core
type CoreAccountRecord struct {
	Accountid     string
	Balance       xdr.Int64
	Seqnum        int64
	Numsubentries int32
	Inflationdest null.String
	HomeDomain    null.String
	Thresholds    xdr.Thresholds
	Flags         xdr.AccountFlags
}

func (ac CoreAccountRecord) IsAuthRequired() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRequiredFlag) != 0
}

func (ac CoreAccountRecord) IsAuthRevocable() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRevocableFlag) != 0
}
