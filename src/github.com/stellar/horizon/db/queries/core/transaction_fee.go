package core

import (
	sq "github.com/lann/squirrel"
)

// TransactionFeesByLedger is a query that loads all rows from `txfeehistory`
// where ledgerseq matches `Sequence.`
func (q *Q) TransactionFeesByLedger(dest interface{}, seq int32) error {
	sql := sq.Select("ctxfh.*").
		From("txfeehistory ctxfh").
		OrderBy("ctxfh.txindex ASC").
		Where("ctxfh.ledgerseq = ?", seq)

	return q.Select(dest, sql)
}
