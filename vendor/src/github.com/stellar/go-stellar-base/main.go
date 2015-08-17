package stellarbase

import (
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
)

//go:generate rake xdr:update
//go:generate go fmt ./xdr

// One is the value of one whole unit of currency.  Stellar uses 7 fixed digits
// for fractional values, thus One is 10 million (10^7)
const One = 10000000

// AddressToAccountId converts the provided address into a xdr.AccountId
func AddressToAccountId(address string) (result xdr.AccountId, err error) {

	bytes, err := strkey.Decode(strkey.VersionByteAccountID, address)

	if err != nil {
		return
	}

	var raw xdr.Uint256
	copy(raw[:], bytes)
	pk, err := xdr.NewPublicKey(xdr.CryptoKeyTypeKeyTypeEd25519, raw)
	if err != nil {
		return
	}

	result = xdr.AccountId(pk)

	return
}
