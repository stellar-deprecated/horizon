package db

import (
	"github.com/guregu/null"
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

// A row of data from the `accounts` table from stellar-core
type CoreAccountRecord struct {
	Accountid     string
	Balance       int64
	Seqnum        int64
	Numsubentries int32
	Inflationdest null.String
	HomeDomain    null.String
	Thresholds    string
	Flags         int32
}
