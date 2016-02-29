package ingest

import (
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	cq "github.com/stellar/horizon/db/queries/core"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/toid"
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

// NewAccounts returns a slice of history.Account objects, each of which were
// created in the ledger that this bundle represents.
func (lb *LedgerBundle) NewAccounts() (result []history.Account) {

	for id, op := range lb.Operations(xdr.OperationTypeCreateAccount) {
		pubkey := op.Body.MustCreateAccountOp().Destination.MustEd25519()
		raw := make([]byte, 32)
		copy(raw, pubkey[:])
		address := strkey.MustEncode(strkey.VersionByteAccountID, raw)
		result = append(result, history.Account{
			TotalOrderID: history.TotalOrderID{ID: id},
			Address:      address,
		})
	}

	return
}

// Operations provides an easier way to filter operations from a ledger bundle
// based upon type.
func (lb *LedgerBundle) Operations(types ...xdr.OperationType) map[int64]*xdr.Operation {
	// make filter set
	wantedTypes := make(map[xdr.OperationType]bool)
	for _, t := range types {
		wantedTypes[t] = true
	}

	results := make(map[int64]*xdr.Operation)

	for i, tx := range lb.Transactions {
		for opindex, op := range tx.Envelope.Tx.Operations {
			_, wanted := wantedTypes[op.Body.Type]
			if wanted {
				id := toid.New(tx.LedgerSequence, tx.Index, int32(opindex))
				results[id.ToInt64()] = &lb.Transactions[i].Envelope.Tx.Operations[opindex]
			}
		}
	}

	return results
}
