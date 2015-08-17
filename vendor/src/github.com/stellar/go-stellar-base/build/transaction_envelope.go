package build

import (
	"bytes"
	"encoding/base64"
	"errors"

	"github.com/stellar/go-stellar-base/xdr"
)

// TransactionEnvelopeMutator is a interface that wraps the
// MutateTransactionEnvelope operation.  types may implement this interface to
// specify how they modify an xdr.TransactionEnvelope object
type TransactionEnvelopeMutator interface {
	MutateTransactionEnvelope(*xdr.TransactionEnvelope) error
}

// TransactionEnvelopeBuilder helps you build a TransactionEnvelope
type TransactionEnvelopeBuilder struct {
	E   xdr.TransactionEnvelope
	Err error
}

// Mutate applies the provided TransactionEnvelopeMutators to this builder's
// envelope
func (b *TransactionEnvelopeBuilder) Mutate(muts ...TransactionEnvelopeMutator) {
	for _, m := range muts {
		err := m.MutateTransactionEnvelope(&b.E)
		if err != nil {
			b.Err = err
			return
		}
	}
}

// MutateTX runs Mutate on the underlying transaction using the provided
// mutators.
func (b *TransactionEnvelopeBuilder) MutateTX(muts ...TransactionMutator) {
	if b.Err != nil {
		return
	}

	txb := TransactionBuilder{TX: b.E.Tx}
	txb.Mutate(muts...)
	b.E.Tx = txb.TX
	b.Err = txb.Err
}

// Bytes encodes the builder's underlying envelope to XDR
func (b TransactionEnvelopeBuilder) Bytes() ([]byte, error) {
	if b.Err != nil {
		return nil, b.Err
	}

	var txBytes bytes.Buffer
	_, err := xdr.Marshal(&txBytes, b.E)
	if err != nil {
		return nil, err
	}

	return txBytes.Bytes(), nil
}

// Base64 returns a string which is the xdr-then-base64-encoded form
// of the builder's underlying transaction envelope
func (b TransactionEnvelopeBuilder) Base64() (string, error) {
	bs, err := b.Bytes()
	return base64.StdEncoding.EncodeToString(bs), err
}

// MutateTransactionEnvelope adds a signature to the provided envelope
func (m Sign) MutateTransactionEnvelope(txe *xdr.TransactionEnvelope) error {
	tb := TransactionBuilder{TX: txe.Tx}
	hash, err := tb.Hash()

	if err != nil {
		return err
	}

	if m.Key == nil {
		return errors.New("Invalid key")
	}

	sig := m.Key.Sign(hash[:])

	ds := xdr.DecoratedSignature{
		Hint:      m.Key.Hint(),
		Signature: xdr.Signature(sig[:]),
	}

	txe.Signatures = append(txe.Signatures, ds)
	return nil
}

// MutateTransactionEnvelope for TransactionBuilder causes the underylying
// transaction to be set as the provided envelope's Tx field
func (m TransactionBuilder) MutateTransactionEnvelope(txe *xdr.TransactionEnvelope) error {
	if m.Err != nil {
		return m.Err
	}

	txe.Tx = m.TX
	return nil
}
