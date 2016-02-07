package db

import (
	sq "github.com/lann/squirrel"
)

var CoreSignerRecordSelect sq.SelectBuilder = sq.Select(
	"si.accountid",
	"si.publickey",
	"si.weight",
).From("signers si")
