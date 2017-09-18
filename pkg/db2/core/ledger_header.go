package core

import (
	sq "github.com/Masterminds/squirrel"
)

// LedgerHeaderBySequence is a query that loads a single row from the
// `ledgerheaders` table.
func (q *Q) LedgerHeaderBySequence(dest interface{}, seq int32) error {
	sql := sq.Select("clh.*").
		From("ledgerheaders clh").
		Limit(1).
		Where("clh.ledgerseq = ?", seq)

	return q.Get(dest, sql)
}
