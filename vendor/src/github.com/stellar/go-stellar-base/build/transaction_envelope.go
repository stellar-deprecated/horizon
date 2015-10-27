package build

import (
	"bytes"
	"encoding/base64"

	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
)

// TransactionEnvelopeMutator is a interface that wraps the
// MutateTransactionEnvelope operation.  types may implement this interface to
// specify how they modify an xdr.TransactionEnvelope object
type TransactionEnvelopeMutator interface {
	MutateTransactionEnvelope(*TransactionEnvelopeBuilder) error
}

// TransactionEnvelopeBuilder helps you build a TransactionEnvelope
type TransactionEnvelopeBuilder struct {
	E   *xdr.TransactionEnvelope
	Err error

	child *TransactionBuilder
}

func (b *TransactionEnvelopeBuilder) Init() {
	if b.E == nil {
		b.E = &xdr.TransactionEnvelope{}
	}

	if b.child == nil {
		b.child = &TransactionBuilder{TX: &b.E.Tx}
	}
}

// Mutate applies the provided TransactionEnvelopeMutators to this builder's
// envelope
func (b *TransactionEnvelopeBuilder) Mutate(muts ...TransactionEnvelopeMutator) {
	b.Init()

	for _, m := range muts {
		err := m.MutateTransactionEnvelope(b)
		if err != nil {
			b.Err = err
			return
		}
	}
}

// MutateTX runs Mutate on the underlying transaction using the provided
// mutators.
func (b *TransactionEnvelopeBuilder) MutateTX(muts ...TransactionMutator) {
	b.Init()

	if b.Err != nil {
		return
	}

	b.child.Mutate(muts...)
	b.Err = b.child.Err
}

// Bytes encodes the builder's underlying envelope to XDR
func (b *TransactionEnvelopeBuilder) Bytes() ([]byte, error) {
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
func (b *TransactionEnvelopeBuilder) Base64() (string, error) {
	bs, err := b.Bytes()
	return base64.StdEncoding.EncodeToString(bs), err
}

// ------------------------------------------------------------
//
//   Mutator implementations
//
// ------------------------------------------------------------

// MutateTransactionEnvelope adds a signature to the provided envelope
func (m Sign) MutateTransactionEnvelope(txe *TransactionEnvelopeBuilder) error {
	hash, err := txe.child.Hash()

	if err != nil {
		return err
	}

	kp, err := keypair.Parse(m.Seed)
	if err != nil {
		return err
	}

	sig, err := kp.SignDecorated(hash[:])
	if err != nil {
		return err
	}

	txe.E.Signatures = append(txe.E.Signatures, sig)
	return nil
}

// MutateTransactionEnvelope for TransactionBuilder causes the underylying
// transaction to be set as the provided envelope's Tx field
func (m *TransactionBuilder) MutateTransactionEnvelope(txe *TransactionEnvelopeBuilder) error {
	if m.Err != nil {
		return m.Err
	}

	txe.E.Tx = *m.TX
	newChild := *m
	txe.child = &newChild
	m.TX = &txe.E.Tx
	return nil
}
