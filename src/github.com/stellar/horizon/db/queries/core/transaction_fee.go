package core

import (
	sq "github.com/lann/squirrel"
)

// TransactionFeeByLedger is a query that loads all rows from `txfeehistory`
// where ledgerseq matches `Sequence.`
func (q *Q) TransactionFeeByLedger(dest interface{}, seq int) error {
	sql := sq.Select("ctxfh.*").
		From("txfeehistory ctxfh").
		OrderBy("ctxfh.txindex ASC").
		Where("ctxfh.ledgerseq = ?", seq)

	return q.Select(dest, sql)
}
