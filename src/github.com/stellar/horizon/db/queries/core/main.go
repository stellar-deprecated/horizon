// Package core contains the types that represent queries primarly performed
// against the Stellar core database.
package core

import (
	"github.com/stellar/horizon/db2"
)

// Q is a helper struct on which to hang common queries against a stellar
// core database.
type Q struct {
	*db2.Repo
}

// LatestLedger loads the latest known ledger
func (q *Q) LatestLedger(dest interface{}) error {
	return q.GetRaw(dest, `SELECT COALESCE(MAX(ledgerseq), 0) FROM ledgerheaders`)
}
