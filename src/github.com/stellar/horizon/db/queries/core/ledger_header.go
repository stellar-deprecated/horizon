package core

import (
	sq "github.com/lann/squirrel"
)

// LedgerHeaderBySequence is a query that loads a single row from the
// `ledgerheaders` table.
func (q *Q) LedgerHeaderBySequence(dest interface{}, seq int) error {
	sql := sq.Select("clh.*").
		From("ledgerheaders clh").
		Limit(1).
		Where("clh.ledgerseq = ?", seq)

	return q.Get(dest, sql)
}
