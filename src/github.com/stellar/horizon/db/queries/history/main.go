// Package history contains the types that represent queries primarly performed
// against the horizon database.
package history

import (
	"github.com/stellar/horizon/db"
)

// TransactionByHash is a query that loads a single
type TransactionByHash struct {
	db.SqlQuery
	Hash string
}
