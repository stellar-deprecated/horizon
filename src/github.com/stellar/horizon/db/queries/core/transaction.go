package core

import (
	sq "github.com/lann/squirrel"
)

// TransactionsByLedger is a query that loads all rows from `txhistory` where
// ledgerseq matches `Sequence.`
func (q *Q) TransactionsByLedger(dest interface{}, seq int32) error {
	sql := sq.Select("ctxh.*").
		From("txhistory ctxh").
		OrderBy("ctxh.txindex ASC").
		Where("ctxh.ledgerseq = ?", seq)

	return q.Select(dest, sql)
}
