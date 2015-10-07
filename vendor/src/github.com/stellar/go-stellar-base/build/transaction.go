package build

import (
	"bytes"
	"encoding/hex"
	"fmt"

	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// Transaction groups the creation of a new TransactionBuilder with a call
// to Mutate.
func Transaction(muts ...TransactionMutator) (result *TransactionBuilder) {
	result = &TransactionBuilder{}
	result.Mutate(Defaults{})
	for _, m := range muts {
		m.MutateTransaction(result)
	}
	return
}

// TransactionMutator is a interface that wraps the
// MutateTransaction operation.  types may implement this interface to
// specify how they modify an xdr.Transaction object
type TransactionMutator interface {
	MutateTransaction(*TransactionBuilder) error
}

// TransactionBuilder represents a Transaction that is being constructed.
type TransactionBuilder struct {
	TX        *xdr.Transaction
	NetworkID [32]byte
	Err       error
}

// Mutate applies the provided TransactionMutators to this builder's transaction
func (b *TransactionBuilder) Mutate(muts ...TransactionMutator) {
	if b.TX == nil {
		b.TX = &xdr.Transaction{}
	}

	for _, m := range muts {
		err := m.MutateTransaction(b)
		if err != nil {
			b.Err = err
			return
		}
	}
}

// Hash returns the hash of this builder's transaction.
func (b *TransactionBuilder) Hash() ([32]byte, error) {
	var txBytes bytes.Buffer

	_, err := fmt.Fprintf(&txBytes, "%s", b.NetworkID)
	if err != nil {
		return [32]byte{}, err
	}

	_, err = xdr.Marshal(&txBytes, xdr.EnvelopeTypeEnvelopeTypeTx)
	if err != nil {
		return [32]byte{}, err
	}

	_, err = xdr.Marshal(&txBytes, b.TX)
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
	result.Mutate(b)

	for _, s := range signers {
		result.Mutate(Sign{s})
	}

	return
}

// ------------------------------------------------------------
//
//   Mutator implementations
//
// ------------------------------------------------------------

// MutateTransaction for Defaults sets reasonable defaults on the transaction being built
func (m Defaults) MutateTransaction(o *TransactionBuilder) error {
	o.TX.Fee = 100
	memo, err := xdr.NewMemo(xdr.MemoTypeMemoNone, nil)
	o.TX.Memo = memo
	o.NetworkID = DefaultNetwork.ID()
	return err
}

// MutateTransaction for SourceAccount sets the transaction's SourceAccount
// to the pubilic key for the address provided
func (m SourceAccount) MutateTransaction(o *TransactionBuilder) error {
	aid, err := stellarbase.AddressToAccountId(m.Address)
	o.TX.SourceAccount = aid
	return err
}

// MutateTransaction for PaymentBuilder causes the underylying PaymentOp
// to be added to the operation list for the provided transaction
func (m PaymentBuilder) MutateTransaction(o *TransactionBuilder) error {
	if m.Err != nil {
		return m.Err
	}

	m.O.Body, m.Err = xdr.NewOperationBody(xdr.OperationTypePayment, m.P)
	o.TX.Operations = append(o.TX.Operations, m.O)
	return m.Err
}

// MutateTransaction for CreateAccountBuilder causes the underylying
// CreateAccountOp to be added to the operation list for the provided
// transaction
func (m CreateAccountBuilder) MutateTransaction(o *TransactionBuilder) error {
	if m.Err != nil {
		return m.Err
	}

	m.O.Body, m.Err = xdr.NewOperationBody(xdr.OperationTypeCreateAccount, m.CA)
	o.TX.Operations = append(o.TX.Operations, m.O)
	return m.Err
}

// MutateTransaction for Sequence sets the SeqNum on the transaction.
func (m Sequence) MutateTransaction(o *TransactionBuilder) error {
	o.TX.SeqNum = xdr.SequenceNumber(m.Sequence)
	return nil
}

// MutateTransaction for Network sets the Network ID to use when signing this transaction
func (m Network) MutateTransaction(o *TransactionBuilder) error {
	o.NetworkID = m.ID()
	return nil
}
