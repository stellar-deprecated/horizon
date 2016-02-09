package db

import (
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/db/records/history"
)

type AccountRecord struct {
	core.Account
	History    history.Account
	Trustlines []core.Trustline
	Signers    []core.Signer
}
