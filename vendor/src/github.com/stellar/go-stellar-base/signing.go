package stellarbase

import (
	"bytes"
	"errors"

	"github.com/agl/ed25519"
)

const RawSeedSize = 32

type RawSeed [RawSeedSize]byte

type Verifier interface {
	Address() string
	Verify(message []byte, signature Signature) bool
}

type Signer interface {
	Seed() string
	Hint() [4]byte
	Sign(message []byte) Signature
}

type PrivateKey struct {
	rawSeed RawSeed
	keyData [ed25519.PrivateKeySize]byte
}

type PublicKey struct {
	keyData [ed25519.PublicKeySize]byte
}

type Signature [ed25519.SignatureSize]byte

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
	decoded, err := DecodeBase58Check(VersionByteSeed, seed)

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

func (privateKey *PrivateKey) PublicKey() PublicKey {
	var pub [ed25519.PublicKeySize]byte
	copy(privateKey.keyData[32:], pub[:])
	return PublicKey{pub}
}

func (privateKey *PrivateKey) Seed() string {
	return EncodeBase58Check(VersionByteSeed, privateKey.rawSeed[:])
}

func (publicKey *PublicKey) Verify(message []byte, signature Signature) bool {
	sig := [ed25519.SignatureSize]byte(signature)

	return ed25519.Verify(&publicKey.keyData, message, &sig)
}

func (publicKey *PublicKey) Address() string {
	return EncodeBase58Check(VersionByteAccountID, publicKey.keyData[:])
}

func (privateKey *PrivateKey) Address() string {
	return EncodeBase58Check(VersionByteAccountID, privateKey.keyData[32:])
}

func (publicKey *PublicKey) KeyData() [ed25519.PublicKeySize]byte {
	return publicKey.keyData
}

func (privateKey *PrivateKey) KeyData() [ed25519.PrivateKeySize]byte {
	return privateKey.keyData
}

func (publicKey *PublicKey) Hint() (r [4]byte) {
	copy(r[:], publicKey.keyData[0:4])
	return
}

func (privateKey *PrivateKey) Hint() (r [4]byte) {
	copy(r[:], privateKey.keyData[0:4])
	return
}
