package db

import (
	sq "github.com/lann/squirrel"
)

// Retrieves the latest ledgers for stellar-core and horizon.
//
type LedgerStateQuery struct {
	Horizon SqlQuery
	Core    SqlQuery
}

func (q LedgerStateQuery) Get() ([]interface{}, error) {
	hSql := sq.
		Select("MAX(sequence) as horizonsequence").
		From("history_ledgers")

	scSql := sq.
		Select("MAX(ledgerseq) as stellarcoresequence").
		From("ledgerheaders")

	var result LedgerState

	err := q.Horizon.Get(hSql, &result)

	if err != nil {
		return nil, err
	}

	err = q.Core.Get(scSql, &result)

	if err != nil {
		return nil, err
	}

	return []interface{}{result}, nil
}

func (l LedgerStateQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 1
}
