package xdr

import (
	"errors"
	"github.com/stellar/go-stellar-base/strkey"
)

// SetAddress modifies the receiver, setting it's value to the AccountId form
// of the provided address.
func (aid *AccountId) SetAddress(address string) error {
	if aid == nil {
		return nil
	}

	raw, err := strkey.Decode(strkey.VersionByteAccountID, address)
	if err != nil {
		return err
	}

	if len(raw) != 32 {
		return errors.New("invalid address")
	}

	var ui Uint256
	copy(ui[:], raw)

	*aid, err = NewAccountId(CryptoKeyTypeKeyTypeEd25519, ui)

	return err
}
