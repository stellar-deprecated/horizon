package stellarbase

import (
	"bytes"
	"errors"

	"github.com/agl/ed25519"
	"github.com/stellar/go-stellar-base/strkey"
)

// RawSeedSize is 32 bytes, the size of a raw (i.e. not encoded as a strkey)
// ed25519 seed
const RawSeedSize = 32

// RawSeed is a ed25519 seed value
type RawSeed [RawSeedSize]byte

// Verifier implementors can validate signatures
type Verifier interface {
	Address() string
	Verify(message []byte, signature Signature) bool
}

// Signer implementors can create signatures
type Signer interface {
	Seed() string
	Hint() [4]byte
	Sign(message []byte) Signature
}

// PrivateKey is the type representing an ed25519 private key, as used
// by the stellar network
type PrivateKey struct {
	rawSeed RawSeed
	keyData [ed25519.PrivateKeySize]byte
}

// PublicKey is the type representing an ed25519 privpublicate key, as used
// by the stellar network
type PublicKey struct {
	keyData [ed25519.PublicKeySize]byte
}

// Signature is a raw ed25519 signature
type Signature [ed25519.SignatureSize]byte

// NewRawSeed convertes the provided byte slice into a RawSeed,
// after confirming it is compatible.
func NewRawSeed(data []byte) (RawSeed, error) {
	var result RawSeed

	if len(data) != RawSeedSize {
		return result, errors.New("Invalid seed size, must be 32 bytes")
	}

	copy(result[:], data[:])
	return result, nil
}

func GenerateKeyFromRawSeed(rawSeed RawSeed) (publicKey PublicKey, privateKey PrivateKey, err error) {
	reader := bytes.NewReader(rawSeed[:])
	pub, priv, err := ed25519.GenerateKey(reader)

	if err != nil {
		return
	}

	privateKey = PrivateKey{rawSeed, *priv}
	publicKey = PublicKey{*pub}
	return
}

func GenerateKeyFromSeed(seed string) (publicKey PublicKey, privateKey PrivateKey, err error) {
	decoded, err := strkey.Decode(strkey.VersionByteSeed, seed)

	if err != nil {
		return
	}

	rawSeed, err := NewRawSeed(decoded)

	if err != nil {
		return
	}

	return GenerateKeyFromRawSeed(rawSeed)
}

func (privateKey *PrivateKey) Sign(message []byte) Signature {
	return *ed25519.Sign(&privateKey.keyData, message)
}

// PublicKey returns the raw ed25519 public key for this PrivateKey
func (privateKey *PrivateKey) PublicKey() PublicKey {
	var pub [ed25519.PublicKeySize]byte
	copy(pub[:], privateKey.keyData[32:])
	return PublicKey{pub}
}

// Seed returns the strkey encoded Seed for this PrivateKey
func (privateKey *PrivateKey) Seed() string {
	return strkey.MustEncode(strkey.VersionByteSeed, privateKey.rawSeed[:])
}

func (publicKey *PublicKey) Verify(message []byte, signature Signature) bool {
	sig := [ed25519.SignatureSize]byte(signature)

	return ed25519.Verify(&publicKey.keyData, message, &sig)
}

// Address returns the StrKey encoded form of the PublicKey
func (publicKey *PublicKey) Address() string {
	return strkey.MustEncode(strkey.VersionByteAccountID, publicKey.keyData[:])
}

// Address returns the StrKey encoded form of the PublicKey associated with this
// PrivateKey.
func (privateKey *PrivateKey) Address() string {
	return strkey.MustEncode(strkey.VersionByteAccountID, privateKey.keyData[32:])
}

// KeyData returns the raw key data
func (publicKey *PublicKey) KeyData() [ed25519.PublicKeySize]byte {
	return publicKey.keyData
}

// KeyData returns the raw key data
func (privateKey *PrivateKey) KeyData() [ed25519.PrivateKeySize]byte {
	return privateKey.keyData
}

func (publicKey *PublicKey) Hint() (r [4]byte) {
	copy(r[:], publicKey.keyData[28:])
	return
}

func (privateKey *PrivateKey) Hint() [4]byte {
	pub := privateKey.PublicKey()
	return pub.Hint()
}
