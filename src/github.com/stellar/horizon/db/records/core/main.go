// Package core contains database record definitions useable for
// reading rows from a Stellar Core db
package core

import (
	"github.com/guregu/null"
	"github.com/stellar/go-stellar-base/xdr"
)

// Account is a row of data from the `accounts` table
type Account struct {
	Accountid     string
	Balance       xdr.Int64
	Seqnum        string
	Numsubentries int32
	Inflationdest null.String
	HomeDomain    null.String
	Thresholds    xdr.Thresholds
	Flags         xdr.AccountFlags
}

// LedgerHeader is row of data from the `ledgerheaders` table
type LedgerHeader struct {
	Hash           string `db:"ledgerhash"`
	PrevHash       string `db:"prevhash"`
	BucketListHash string `db:"bucketlisthash"`
	Sequence       uint32 `db:"ledgerseq"`
	EnvelopeXDR    string `db:"txbody"`
	ResultXDR      string `db:"txresult"`
	ResultMetaXDR  string `db:"txmeta"`
}
