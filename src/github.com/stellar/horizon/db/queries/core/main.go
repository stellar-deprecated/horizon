// Package core contains the types that represent queries primarly performed
// against the Stellar core database.
package core

import (
	"github.com/stellar/horizon/db"
)

// TransactionByHash is a query that loads a single row from the `txfeehistory`
// table where ``
type TransactionByHash struct {
	DB   db.SqlQuery
	Hash string
}

// TransactionFeeByHash is a query that loads a single
type TransactionFeeByHash struct {
	DB   db.SqlQuery
	Hash string
}
