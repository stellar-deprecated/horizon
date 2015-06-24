package build

import (
	"bytes"
	"encoding/hex"
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

// Hex returns a string which is the xdr-then-hex-encoded form
// of the builder's underlying transaction envelope
func (b TransactionEnvelopeBuilder) Hex() (string, error) {
	bs, err := b.Bytes()

	return hex.EncodeToString(bs), err
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
		Signature: xdr.Uint512(sig),
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
