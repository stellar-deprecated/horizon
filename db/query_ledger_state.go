package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// LedgerStateQuery retrieves the latest ledgers for stellar-core and horizon.
type LedgerStateQuery struct {
	Horizon SqlQuery
	Core    SqlQuery
}

// Get executes the query, returning any found results
func (q LedgerStateQuery) Select(ctx context.Context, dest interface{}) error {
	hSql := sq.
		Select("MAX(sequence) as horizonsequence").
		From("history_ledgers")

	scSql := sq.
		Select("MAX(ledgerseq) as stellarcoresequence").
		From("ledgerheaders")

	var result LedgerState

	err := q.Horizon.Get(ctx, hSql, &result)

	if err != nil {
		return err
	}

	err = q.Core.Get(ctx, scSql, &result)

	if err != nil {
		return err
	}

	setOn([]LedgerState{result}, dest)
	return nil
}
