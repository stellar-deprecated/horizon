package txsub

import (
	"errors"
	"fmt"
	"github.com/stellar/go-stellar-base/xdr"
)

var (
	ErrNoResults = errors.New("No result found")
)

// FailedTransactionError represent an error that occurred because
// stellar-core rejected the transaction.  ResultXDR is a base64
// encoded TransactionResult struct
type FailedTransactionError struct {
	ResultXDR string
}

func (err *FailedTransactionError) Error() string {
	return fmt.Sprintf("tx failed: %s", err.ResultXDR)
}

func (fte *FailedTransactionError) Result() (result xdr.TransactionResult, err error) {
	err = xdr.SafeUnmarshalBase64(fte.ResultXDR, &result)
	return
}

// MalformedTransactionError represent an error that occurred because
// a TransactionEnvelope could not be decoded from the provided data.
type MalformedTransactionError struct {
	EnvelopeXDR string
}

func (err *MalformedTransactionError) Error() string {
	return "tx malformed"
}
