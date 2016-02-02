package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// LedgerState represents the latest known ledgers for both
// horizon and stellar-core.
type LedgerState struct {
	HorizonSequence     int32
	StellarCoreSequence int32
}

// UpToDate return true if the history state is up to date with the stellar-core
// state.
func (s *LedgerState) UpToDate() bool {
	return s.HorizonSequence >= s.StellarCoreSequence
}

// LedgerStateQuery retrieves the latest ledgers for stellar-core and horizon.
type LedgerStateQuery struct {
	Horizon SqlQuery
	Core    SqlQuery
}

// Select executes the query, returning any found results
func (q LedgerStateQuery) Select(ctx context.Context, dest interface{}) error {
	hSQL := sq.
		Select("COALESCE(MAX(sequence), 0) as horizonsequence").
		From("history_ledgers")

	scSQL := sq.
		Select("COALESCE(MAX(ledgerseq), 0) as stellarcoresequence").
		From("ledgerheaders")

	var result LedgerState

	err := q.Horizon.Get(ctx, hSQL, &result)

	if err != nil {
		return err
	}

	err = q.Core.Get(ctx, scSQL, &result)

	if err != nil {
		return err
	}

	setOn([]LedgerState{result}, dest)
	return nil
}
