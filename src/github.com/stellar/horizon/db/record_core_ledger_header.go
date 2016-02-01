package db

import (
	// "database/sql"
	sq "github.com/lann/squirrel"
	// "golang.org/x/net/context"
)

var CoreLedgerHeaderRecordSelect = sq.Select("clh.*").From("ledgerheaders clh")

// CoreLedgerHeaderRecord is row of data from the `ledgerheaders` table from
// stellar-core
type CoreLedgerHeaderRecord struct {
	Hash           string `db:"ledgerhash"`
	PrevHash       string `db:"prevhash"`
	BucketListHash string `db:"bucketlisthash"`
	Sequence       uint32 `db:"ledgerseq"`
	EnvelopeXDR    string `db:"txbody"`
	ResultXDR      string `db:"txresult"`
	ResultMetaXDR  string `db:"txmeta"`
}
