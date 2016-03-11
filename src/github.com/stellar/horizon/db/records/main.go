// Package records contains data types that represent database records that
// cut across multiple areas of horizon's concern.  For example, a record that
// represents data loaded from both the Stellar Core and History databases.
package records

import (
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db/records/history"
)

// Account represents account data loaded from both the history db AND
// the core db.
type Account struct {
	core.Account
	History    history.Account
	Trustlines []core.Trustline
	Signers    []core.Signer
}
