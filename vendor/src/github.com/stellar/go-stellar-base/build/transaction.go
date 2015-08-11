package build

import (
	"bytes"
	"encoding/hex"

	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// Transaction groups the creation of a new TransactionBuilder with a call
// to Mutate.
func Transaction(muts ...TransactionMutator) (result TransactionBuilder) {
	result.Mutate(Defaults{})
	for _, m := range muts {
		m.MutateTransaction(&result.TX)
	}
	return
}

// TransactionMutator is a interface that wraps the
// MutateTransaction operation.  types may implement this interface to
// specify how they modify an xdr.Transaction object
type TransactionMutator interface {
	MutateTransaction(*xdr.Transaction) error
}

// TransactionBuilder represents a Transaction that is being constructed.
type TransactionBuilder struct {
	TX  xdr.Transaction
	Err error
}

// Mutate applies the provided TransactionMutators to this builder's transaction
func (b *TransactionBuilder) Mutate(muts ...TransactionMutator) {
	for _, m := range muts {
		err := m.MutateTransaction(&b.TX)
		if err != nil {
			b.Err = err
			return
		}
	}
}

// Hash returns the hash of this builder's transaction.
func (b *TransactionBuilder) Hash() ([32]byte, error) {
	var txBytes bytes.Buffer
	_, err := xdr.Marshal(&txBytes, b.TX)
	if err != nil {
		return [32]byte{}, err
	}

	return stellarbase.Hash(txBytes.Bytes()), nil
}

// HashHex returns the hex-encoded hash of this builder's transaction
func (b *TransactionBuilder) HashHex() (string, error) {
	hash, err := b.Hash()
	if err != nil {
		return "", err
	}

	return hex.EncodeToString(hash[:]), nil
}

// Sign returns an new TransactionEnvelopeBuilder using this builder's
// transaction as the basis and with signatures of that transaction from the
// provided Signers.
func (b *TransactionBuilder) Sign(signers ...stellarbase.Signer) (result TransactionEnvelopeBuilder) {
	result.Mutate(*b)

	for _, s := range signers {
		result.Mutate(Sign{s})
	}

	return
}

// MutateTransaction for SourceAccount sets the transaction's SourceAccount
// to the pubilic key for the address provided
func (m Defaults) MutateTransaction(o *xdr.Transaction) error {
	o.Fee = 10
	memo, err := xdr.NewMemo(xdr.MemoTypeMemoNone, nil)
	o.Memo = memo
	return err
}

// MutateTransaction for SourceAccount sets the transaction's SourceAccount
// to the pubilic key for the address provided
func (m SourceAccount) MutateTransaction(o *xdr.Transaction) error {
	aid, err := stellarbase.AddressToAccountId(m.Address)
	o.SourceAccount = aid
	return err
}

// MutateTransaction for PaymentBuilder causes the underylying PaymentOp
// to be added to the operation list for the provided transaction
func (m PaymentBuilder) MutateTransaction(o *xdr.Transaction) error {
	if m.Err != nil {
		return m.Err
	}

	m.O.Body, m.Err = xdr.NewOperationBody(xdr.OperationTypePayment, m.P)
	o.Operations = append(o.Operations, m.O)
	return m.Err
}

// MutateTransaction for CreateAccountBuilder causes the underylying
// CreateAccountOp to be added to the operation list for the provided
// transaction
func (m CreateAccountBuilder) MutateTransaction(o *xdr.Transaction) error {
	if m.Err != nil {
		return m.Err
	}

	m.O.Body, m.Err = xdr.NewOperationBody(xdr.OperationTypeCreateAccount, m.CA)
	o.Operations = append(o.Operations, m.O)
	return m.Err
}

// MutateTransaction for Sequence sets the SeqNum on the transaction.
func (m Sequence) MutateTransaction(o *xdr.Transaction) error {
	o.SeqNum = xdr.SequenceNumber(m.Sequence)
	return nil
}
