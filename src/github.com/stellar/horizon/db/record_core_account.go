package db

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
