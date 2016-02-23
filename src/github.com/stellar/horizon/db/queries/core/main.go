// Package core contains the types that represent queries primarly performed
// against the Stellar core database.
package core

import (
	"github.com/stellar/horizon/db"
)

// TransactionByHash is a query that loads a single
type TransactionByHash struct {
	db.SqlQuery
	Hash string
}
