// Package participants contains functions to derive a set of "participant"
// addresses for various data structures in the Stellar network's ledger.
package participants

import (
	"fmt"

	"github.com/stellar/go-stellar-base/xdr"
)

// ForChanges returns all the participating accounts from the provided
// ledger changes.
func ForChanges(
	changes *xdr.LedgerEntryChanges,
) (result []xdr.AccountId, err error) {

	for _, c := range *changes {
		var account *xdr.AccountId

		switch c.Type {
		case xdr.LedgerEntryChangeTypeLedgerEntryCreated:
			account = forLedgerEntry(c.MustCreated())
		case xdr.LedgerEntryChangeTypeLedgerEntryRemoved:
			account = forLedgerKey(c.MustRemoved())
		case xdr.LedgerEntryChangeTypeLedgerEntryUpdated:
			account = forLedgerEntry(c.MustUpdated())
		case xdr.LedgerEntryChangeTypeLedgerEntryState:
			account = forLedgerEntry(c.MustState())
		default:
			err = fmt.Errorf("Unknown change type: %s", c.Type)
			return
		}

		if account != nil {
			result = append(result, *account)
		}
	}

	return
}

// ForMeta returns all the participating accounts from the provided
// transaction meta.
func ForMeta(
	meta *xdr.TransactionMeta,
) (result []xdr.AccountId, err error) {

	if meta.Operations == nil {
		return
	}

	for _, op := range *meta.Operations {
		var acc []xdr.AccountId
		acc, err = ForChanges(&op.Changes)
		if err != nil {
			return
		}

		result = append(result, acc...)
	}

	return
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
		result = append(result, op.Body.MustDestination())
	case xdr.OperationTypeInflation:
		// the only direct participant is the source_account
	case xdr.OperationTypeManageData:
		// the only direct participant is the source_account
	default:
		err = fmt.Errorf("Unknown operation type: %s", op.Body.Type)
	}

	return
}

// ForTransaction returns all the participating accounts from the provided
// transaction.
func ForTransaction(tx *xdr.TransactionEnvelope) ([]string, error) {
	return nil, nil
}

func forLedgerEntry(le xdr.LedgerEntry) *xdr.AccountId {
	if le.Data.Type != xdr.LedgerEntryTypeAccount {
		return nil
	}
	aid := le.Data.MustAccount().AccountId
	return &aid
}

func forLedgerKey(lk xdr.LedgerKey) *xdr.AccountId {
	if lk.Type != xdr.LedgerEntryTypeAccount {
		return nil
	}
	aid := lk.MustAccount().AccountId
	return &aid
}
