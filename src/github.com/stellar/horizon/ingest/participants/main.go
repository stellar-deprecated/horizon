// Package participants contains functions to derive a set of "participant"
// addresses for various data structures in the Stellar network's ledger.
package participants

import (
	"fmt"

	"github.com/stellar/go-stellar-base/xdr"
)

// ForFeeMeta returns all the participating accounts from the provided
// transaction fee meta.
func ForFeeMeta(meta *xdr.LedgerEntryChanges) ([]string, error) {
	return nil, nil
}

// ForMeta returns all the participating accounts from the provided
// transaction meta.
func ForMeta(meta *xdr.TransactionMeta) ([]string, error) {
	return nil, nil
}

// ForOperation returns all the participating accounts from the
// provided operation.
func ForOperation(
	op *xdr.Operation,
) (result []xdr.AccountId, err error) {

	if op.SourceAccount != nil {
		result = append(result, *op.SourceAccount)
	}

	switch op.Body.Type {
	case xdr.OperationTypeCreateAccount:
		result = append(result, op.Body.MustCreateAccountOp().Destination)
	case xdr.OperationTypePayment:
		result = append(result, op.Body.MustPaymentOp().Destination)
	case xdr.OperationTypePathPayment:
		result = append(result, op.Body.MustPathPaymentOp().Destination)
	case xdr.OperationTypeManageOffer:
		// the only direct participant is the source_account
	case xdr.OperationTypeCreatePassiveOffer:
		// the only direct participant is the source_account
	case xdr.OperationTypeSetOptions:
		// the only direct participant is the source_account
	case xdr.OperationTypeChangeTrust:
		// the only direct participant is the source_account
	case xdr.OperationTypeAllowTrust:
		result = append(result, op.Body.MustAllowTrustOp().Trustor)
	case xdr.OperationTypeAccountMerge:
	case xdr.OperationTypeInflation:
		// the only direct participant is the source_account
	case xdr.OperationTypeManageData:
		// the only direct participant is the source_account
	default:
		panic(fmt.Errorf("Unknown operation type: %s", op.Body.Type))
	}

	return
}

// ForTransaction returns all the participating accounts from the provided
// transaction.
func ForTransaction(tx *xdr.TransactionEnvelope) ([]string, error) {
	return nil, nil
}
