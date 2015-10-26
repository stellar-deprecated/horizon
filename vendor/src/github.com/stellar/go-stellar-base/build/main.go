// Package build provides a builder system for constructing various xdr
// structures used by the stellar network.
//
// At the core of this package is the *Builder and *Mutator types.  A Builder
// object (ex. PaymentBuilder, TransactionBuilder) contain an underlying xdr
// struct that is being iteratively built by having zero or more Mutator structs
// applied to it. See ExampleTransactionBuilder in main_test.go for an example.
package build

import (
	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/go-stellar-base/xdr"
)

var (
	PublicNetwork  = Network{network.PublicNetworkPassphrase}
	TestNetwork    = Network{network.TestNetworkPassphrase}
	DefaultNetwork = TestNetwork
)

// Defaults is a mutator that sets defaults
type Defaults struct{}

// Destination is a mutator capable of setting the destination on
// an operations that have one.
type Destination struct {
	AddressOrSeed string
}

// SourceAccount is a mutator capable of setting the source account on
// an xdr.Operation and an xdr.Transaction
type SourceAccount struct {
	AddressOrSeed string
}

// NativeAmount is a mutator that configures a payment to be using native
// currency and have the amount provided.
type NativeAmount struct {
	Amount string
}

// Sequence is a mutator that sets the sequence number on a transaction
type Sequence struct {
	Sequence xdr.SequenceNumber
}

// Sign is a mutator that contributes a signature of the provided envelope's
// transaction with the configured key
type Sign struct {
	Seed string
}

// Network establishes the stellar network that a transaction should apply to.
// This modifier influences how a transaction is hashed for the purposes of signature generation.
type Network struct {
	Passphrase string
}

func (n *Network) ID() [32]byte {
	return network.ID(n.Passphrase)
}
