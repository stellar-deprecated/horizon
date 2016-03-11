package ingest

import (
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/core"
)

// Load runs queries against `core` to fill in the records of the bundle.
func (lb *LedgerBundle) Load(db *db2.Repo) error {
	q := &core.Q{db}

	// Load Header
	err := q.LedgerHeaderBySequence(&lb.Header, lb.Sequence)
	if err != nil {
		return err
	}

	// Load transactions
	err = q.TransactionsByLedger(&lb.Transactions, lb.Sequence)

	if err != nil {
		return err
	}

	err = q.TransactionFeesByLedger(&lb.TransactionFees, lb.Sequence)
	if err != nil {
		return err
	}

	return nil
}
