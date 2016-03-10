// Package core contains the types that represent queries primarly performed
// against the Stellar core database.
package core

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db2"
)

// Q is a helper struct on which to hang common queries against a stellar
// core database.
type Q struct {
	*db2.Repo
}

// TransactionByHash is a query that loads a single row from the `txhistory`.
type TransactionByHash struct {
	DB   db.SqlQuery
	Hash string
}

// TransactionByLedger is a query that loads all rows from `txhistory` where
// ledgerseq matches `Sequence.`
type TransactionByLedger struct {
	DB       db.SqlQuery
	Sequence int32
}
