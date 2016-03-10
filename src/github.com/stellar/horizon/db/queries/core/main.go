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
