package ingest

import (
	"github.com/stellar/horizon/db"
	cq "github.com/stellar/horizon/db/queries/core"
	"golang.org/x/net/context"
)

// Load runs queries against `core` to fill in the records of the bundle.
func (lb *LedgerBundle) Load(core db.SqlQuery) error {
	ctx := context.Background()

	// Load Header
	err := db.Get(ctx, &cq.LedgerHeaderBySequence{
		DB:       core,
		Sequence: lb.Sequence,
	}, &lb.Header)
	if err != nil {
		return err
	}

	// Load transactions
	err = db.Select(ctx, &cq.TransactionByLedger{
		DB:       core,
		Sequence: lb.Sequence,
	}, &lb.Transactions)
	if err != nil {
		return err
	}

	// Load fees
	err = db.Select(ctx, &cq.TransactionFeeByLedger{
		DB:       core,
		Sequence: lb.Sequence,
	}, &lb.TransactionFees)
	if err != nil {
		return err
	}

	return nil
}
