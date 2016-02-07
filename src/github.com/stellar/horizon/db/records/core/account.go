package core

import (
	"github.com/stellar/go-stellar-base/xdr"
)

// IsAuthRequired returns true if the account has the "AUTH_REQUIRED" option
// turned on.
func (ac Account) IsAuthRequired() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRequiredFlag) != 0
}

// IsAuthRevocable returns true if the account has the "AUTH_REVOCABLE" option
// turned on.
func (ac Account) IsAuthRevocable() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRevocableFlag) != 0
}
