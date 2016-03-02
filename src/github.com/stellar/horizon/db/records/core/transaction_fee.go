package core

import (
	"github.com/stellar/go-stellar-base/xdr"
)

// ChangesXDR returns the XDR encoded changes for this transaction fee
func (fee *TransactionFee) ChangesXDR() string {
	out, err := xdr.MarshalBase64(fee.Changes)
	if err != nil {
		panic(err)
	}
	return out
}
