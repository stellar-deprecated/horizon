package build

import "github.com/stellar/go-stellar-base/xdr"
import "github.com/stellar/go-stellar-base"

// OperationMutator is a interface that wraps the
// MutateOperation operation.  types may implement this interface to
// specify how they modify an xdr.Operation object
type OperationMutator interface {
	MutateOperation(*xdr.Operation) error
}

// MutateOperation for SourceAccount sets the operation's SourceAccount
// to the pubilic key for the address provided
func (m SourceAccount) MutateOperation(o *xdr.Operation) error {
	aid, err := stellarbase.AddressToAccountId(m.Address)
	o.SourceAccount = &aid
	return err
}
