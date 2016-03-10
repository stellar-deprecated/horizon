// Package history contains the types that represent queries primarly performed
// against the horizon database.
package history

import (
	"github.com/stellar/horizon/db2"
)

// Q is a helper struct on which to hang common queries against a horizon
// database.
type Q struct {
	*db2.Repo
}
