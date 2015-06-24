package stellarbase

import (
	"errors"
	"fmt"
	"math/big"
	"strconv"
	"strings"
)

const alphabet = "gsphnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCr65jkm8oFqi1tuvAxyz"

var decodeMap [256]byte

func init() {
	for i := 0; i < len(decodeMap); i++ {
		decodeMap[i] = 0xFF
	}
	for i := 0; i < len(alphabet); i++ {
		decodeMap[alphabet[i]] = byte(i)
	}
}

var (
	// ErrNotCheckEncoded represents an error that occurs when you try to decode
	// a string that expects to be base58-check encoded as is not.
	ErrNotCheckEncoded = errors.New("base58: input is not check encoded")
)

// ErrCorruptInput is an error that occurs when decoding base58 encoded
// data.
type ErrCorruptInput int64

func (e ErrCorruptInput) Error() string {
	return "illegal base58 data at input byte " + strconv.FormatInt(int64(e), 10)
}

// ErrInvalidVersionByte is an error that occurs when decoding base58-check
// encoded data using DecodeBase58Check.  It is returned when the actual
// version byte of the encoded value does not match the expected value provided
// to the call
type ErrInvalidVersionByte struct {
	Expected VersionByte
	Actual   VersionByte
}

func (e ErrInvalidVersionByte) Error() string {
	return fmt.Sprintf("illegal base58 version byte expected:%d actual:%d", e.Expected, e.Actual)
}

// VersionByte represents one of the base58-check "version bytes" used by the
// Stellar network
type VersionByte byte

const (
	//VersionByteAccountID is the version byte used for encoded stellar addresses
	VersionByteAccountID VersionByte = 0
	//VersionByteNone is the version byte used for nothing, snoogins.
	VersionByteNone = 1
	//VersionByteSeed is the version byte used for encoded stellar seed
	VersionByteSeed = 33
)

// EncodeBase58 encodes the provided data to base58, using the stellar
// alphabet
func EncodeBase58(src []byte) string {
	bigInt := new(big.Int)
	bigInt.SetBytes(src)
	leadingZeroes := strings.Repeat("g", leadingZeroCount(src))

	var resultSlice = make([]byte, 0, 256)
	var results = []string{
		leadingZeroes,
		string(EncodeBigToBase58(resultSlice, bigInt)),
	}

	return strings.Join(results, "")
}

// EncodeBase58Check encodes the provided data to base58, using the stellar
// alphabet and the provided version byte.
func EncodeBase58Check(version VersionByte, src []byte) string {
	start := []byte{}
	withVersion := append(start, byte(version))
	withPayload := append(withVersion, src...)
	withChecksum := append(withPayload, base58CheckSum(withPayload)...)

	return string(EncodeBase58(withChecksum))
}

// DecodeBase58 decodes the provided data from base58, using the stellar
// alphabet.
func DecodeBase58(src string) ([]byte, error) {
	leadingGs := make([]byte, leadingGCount(src))

	bigInt, err := DecodeBase58ToBig([]byte(src))

	if err != nil {
		return []byte{}, err
	}

	return append(leadingGs, bigInt.Bytes()...), nil
}

// DecodeBase58Check decodes the provided data from base58, using the stellar
// alphabet.  An error is returned if the provided version byte is not the
// byte used in the encoded string.
func DecodeBase58Check(version VersionByte, src string) ([]byte, error) {

	decoded, err := DecodeBase58(src)

	if err != nil {
		return []byte{}, err
	}

	if len(decoded) < 5 {
		return []byte{}, ErrNotCheckEncoded
	}

	decodedVersion := VersionByte(decoded[0])
	payload := decoded[1 : len(decoded)-4]
	checksum := decoded[len(decoded)-4:]

	if decodedVersion != version {
		return []byte{}, ErrInvalidVersionByte{version, decodedVersion}
	}

	_ = checksum //TODO: validate the checksum

	return payload, nil
}

// DecodeBase58ToBig decodes a big integer from the bytes. Returns an error on
// corrupt input.
func DecodeBase58ToBig(src []byte) (*big.Int, error) {
	n := new(big.Int)
	radix := big.NewInt(58)
	for i := 0; i < len(src); i++ {
		b := decodeMap[src[i]]
		if b == 0xFF {
			return nil, ErrCorruptInput(i)
		}
		n.Mul(n, radix)
		n.Add(n, big.NewInt(int64(b)))
	}
	return n, nil
}

// EncodeBigToBase58 encodes src, appending to dst. Be sure to use the returned
// new value of dst.
func EncodeBigToBase58(dst []byte, src *big.Int) []byte {
	start := len(dst)
	n := new(big.Int)
	n.Set(src)
	radix := big.NewInt(58)
	zero := big.NewInt(0)

	for n.Cmp(zero) > 0 {
		mod := new(big.Int)
		n.DivMod(n, radix, mod)
		dst = append(dst, alphabet[mod.Int64()])
	}

	// reverse string
	for i, j := start, len(dst)-1; i < j; i, j = i+1, j-1 {
		dst[i], dst[j] = dst[j], dst[i]
	}
	return dst
}

func base58CheckSum(message []byte) []byte {
	inner := Hash(message)
	outer := Hash(inner[:])
	return outer[0:4]
}

func leadingZeroCount(src []byte) (result int) {
	for _, val := range src {
		if val != 0x00 {
			return
		}
		result++
	}
	return
}

func leadingGCount(src string) (result int) {
	for _, val := range src {
		if val != 'g' {
			return
		}
		result++
	}
	return
}
