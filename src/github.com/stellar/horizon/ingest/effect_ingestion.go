package ingest

import (
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2/history"
)

// Add writes an effect to the database while automatically tracking the index
// to use.
func (ei *EffectIngestion) Add(aid xdr.AccountId, typ history.EffectType, details interface{}) bool {
	if ei.err != nil {
		return false
	}

	ei.added++
	var haid int64
	haid, ei.err = ei.Accounts.Get(aid.Address())
	if ei.err != nil {
		return false
	}

	ei.err = ei.Dest.Effect(haid, ei.OperationID, ei.added, typ, details)
	if ei.err != nil {
		return false
	}

	return true
}

// Finish marks this ingestion as complete, returning any error that was recorded.
func (ei *EffectIngestion) Finish() error {
	err := ei.err
	ei.err = nil
	return err
}
