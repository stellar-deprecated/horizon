// Package core contains the types that represent queries primarly performed
// against the Stellar core database.
package core

import (
	"github.com/stellar/horizon/db"
)

// LedgerHeaderBySequence is a query that loads a single row from the `ledgerheaders`.
type LedgerHeaderBySequence struct {
	DB       db.SqlQuery
	Sequence int32
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

// TransactionFeeByHash is a query that loads a single row from the
// `txfeehistory`.
type TransactionFeeByHash struct {
	DB   db.SqlQuery
	Hash string
}

// TransactionFeeByLedger is a query that loads all rows from `txfeehistory`
// where ledgerseq matches `Sequence.`
type TransactionFeeByLedger struct {
	DB       db.SqlQuery
	Sequence int32
}
