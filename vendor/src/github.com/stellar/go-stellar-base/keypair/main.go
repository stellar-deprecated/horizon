package keypair

import (
	"crypto/rand"
	"errors"
	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
	"io"
)

var (
	// ErrInvalidKey will be returned by operations when the keypair being used
	// could not be decoded.
	ErrInvalidKey = errors.New("invalid key")

	// ErrInvalidSignature is returned when the signature is invalid, either
	// through malformation or if it does not verify the message against the
	// provided public key
	ErrInvalidSignature = errors.New("signature verification failed")

	// ErrCannotSign is returned when attempting to sign a message when
	// the keypair does not have the secret key available
	ErrCannotSign = errors.New("cannot sign")
)

// KP is the main interface for this package
type KP interface {
	Address() string
	Hint() [4]byte
	Verify(input []byte, signature []byte) error
	Sign(input []byte) ([]byte, error)
	SignDecorated(input []byte) (xdr.DecoratedSignature, error)
}

// Random creates a random full keypair
func Random() (KP, error) {
	var rawSeed [32]byte

	_, err := io.ReadFull(rand.Reader, rawSeed[:])
	if err != nil {
		return nil, err
	}

	kp, err := FromRawSeed(rawSeed)

	if err != nil {
		return nil, err
	}

	return kp, nil
}

// Master returns the master keypair for a given network passphrase
func Master(networkPassphrase string) KP {
	kp, err := FromRawSeed(network.ID(networkPassphrase))

	if err != nil {
		panic(err)
	}

	return kp
}

// Parse constructs a new KP from the provided string, which should be either
// an address, or a seed.  If the provided input is a seed, the resulting KP
// will have signing capabilities.
func Parse(addressOrSeed string) (KP, error) {
	_, err := strkey.Decode(strkey.VersionByteAccountID, addressOrSeed)
	if err == nil {
		return &FromAddress{addressOrSeed}, nil
	}

	if err != strkey.ErrInvalidVersionByte {
		return nil, err
	}

	_, err = strkey.Decode(strkey.VersionByteSeed, addressOrSeed)
	if err == nil {
		return &Full{addressOrSeed}, nil
	}

	return nil, err
}

// FromRawSeed creates a new keypair from the provided raw ED25519 seed:w
func FromRawSeed(rawSeed [32]byte) (KP, error) {
	seed, err := strkey.Encode(strkey.VersionByteSeed, rawSeed[:])
	if err != nil {
		return nil, err
	}

	return &Full{seed}, nil
}

func MustParse(addressOrSeed string) KP {
	kp, err := Parse(addressOrSeed)
	if err != nil {
		panic(err)
	}

	return kp
}
