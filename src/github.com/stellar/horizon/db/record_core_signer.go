package db

import (
	sq "github.com/lann/squirrel"
)

var CoreSignerRecordSelect sq.SelectBuilder = sq.Select(
	"si.accountid",
	"si.publickey",
	"si.weight",
).From("signers si")

// A row of data from the `signers` table from stellar-core
type CoreSignerRecord struct {
	Accountid string
	Publickey string
	Weight    int32
}
