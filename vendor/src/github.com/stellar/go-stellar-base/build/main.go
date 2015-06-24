// Package build provides a builder system for constructing various xdr
// structures used by the stellar network.
//
// At the core of this package is the *Builder and *Mutator types.  A Builder
// object (ex. PaymentBuilder, TransactionBuilder) contain an underlying xdr
// struct that is being iteratively built by having zero or more Mutator structs
// applied to it. See ExampleTransactionBuilder in main_test.go for an example.
package build

import (
	"github.com/stellar/go-stellar-base"
	"github.com/stellar/go-stellar-base/xdr"
)

// Defaults is a mutator that sets defaults
type Defaults struct{}

// Destination is a mutator capable of setting the destination on
// an xdr.PaymentOp
type Destination struct {
	Address string
}

// SourceAccount is a mutator capable of setting the source account on
// an xdr.Operation and an xdr.Transaction
type SourceAccount struct {
	Address string
}

// NativeAmount is a mutator that configures a payment to be using native
// currency and have the amount provided.
type NativeAmount struct {
	Amount int64
}

// Sequence is a mutator that sets the sequence number on a transaction
type Sequence struct {
	Sequence xdr.SequenceNumber
}

// Sign is a mutator that contributes a signature of the provided envelope's
// transaction with the configured key
type Sign struct {
	Key stellarbase.Signer
}
