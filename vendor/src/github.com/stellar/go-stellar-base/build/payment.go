package build

import (
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// Payment groups the creation of a new PaymentBuilder with a call to Mutate.
func Payment(muts ...interface{}) (result PaymentBuilder) {
	result.Mutate(muts...)
	return
}

// PaymentMutator is a interface that wraps the
// MutatePayment operation.  types may implement this interface to
// specify how they modify an xdr.PaymentOp object
type PaymentMutator interface {
	MutatePayment(*xdr.PaymentOp) error
}

// PaymentBuilder represents a transaction that is being built.
type PaymentBuilder struct {
	O   xdr.Operation
	P   xdr.PaymentOp
	Err error
}

// Mutate applies the provided mutators to this builder's payment or operation.
func (b *PaymentBuilder) Mutate(muts ...interface{}) {
	for _, m := range muts {
		var err error
		switch mut := m.(type) {
		case PaymentMutator:
			err = mut.MutatePayment(&b.P)
		case OperationMutator:
			err = mut.MutateOperation(&b.O)
		}

		if err != nil {
			b.Err = err
			return
		}
	}
}

// MutatePayment for Destination sets the PaymentOp's Destination field
func (m Destination) MutatePayment(o *xdr.PaymentOp) error {
	aid, err := stellarbase.AddressToAccountId(m.Address)
	o.Destination = aid
	return err
}

// MutatePayment for NativeAmount sets the PaymentOp's currency field to
// native and sets its amount to the provided integer
func (m NativeAmount) MutatePayment(o *xdr.PaymentOp) error {
	asset, err := xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)
	o.Asset = asset
	o.Amount = xdr.Int64(m.Amount)
	return err
}
