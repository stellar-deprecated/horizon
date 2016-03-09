// Package history contains the types that represent queries primarly performed
// against the horizon database.
package history

import (
	"github.com/stellar/horizon/db"
)

// AccountByID loads a row from `history_accounts`, by id
type AccountByID struct {
	DB db.SqlQuery
	ID int64
}

// LatestAccountForAddress looks up `id` from the `history_accounts` table
// by strkey-encoded address.  Will return the latest ID found in the case that
// the provided address has been created, merged, then created again.
type LatestAccountForAddress struct {
	DB      db.SqlQuery
	Address string
}

// TransactionByHash is a query that loads a single row from the
// `history_transactions` table based upon the provided hash.
type TransactionByHash struct {
	DB   db.SqlQuery
	Hash string
}
