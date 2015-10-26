package network

import (
	"github.com/stellar/go-stellar-base/hash"
)

const (
	// PublicNetworkPassphrase is the pass phrase used for every transaction intended for the public stellar network
	PublicNetworkPassphrase = "Public Global Stellar Network ; September 2015"
	// TestNetworkPassphrase is the pass phrase used for every transaction intended for the SDF-run test network
	TestNetworkPassphrase = "Test SDF Network ; September 2015"
)

func ID(passphrase string) [32]byte {
	return hash.Hash([]byte(passphrase))
}
