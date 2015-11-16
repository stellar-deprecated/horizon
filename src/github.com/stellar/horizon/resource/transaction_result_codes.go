package resource

import (
	"github.com/stellar/horizon/txsub"
)

// Populate fills out the details
func (res *TransactionResultCodes) Populate(
	fail *txsub.FailedTransactionError,
) (err error) {

	res.TransactionCode, err = fail.TransactionResultCode()
	if err != nil {
		return
	}

	res.OperationCodes, err = fail.OperationResultCodes()
	if err != nil {
		return
	}

	return
}
