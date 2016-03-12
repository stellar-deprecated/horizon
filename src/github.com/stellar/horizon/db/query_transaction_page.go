package db

import (
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/history"
	"golang.org/x/net/context"
)

type TransactionPageQuery struct {
	SqlQuery
	db2.PageQuery
	AccountAddress string
	LedgerSequence int32
}

func (q TransactionPageQuery) Select(ctx context.Context, dest interface{}) error {
	sql := TransactionRecordSelect.
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("ht.id > ?", cursor).OrderBy("ht.id asc")
	case "desc":
		sql = sql.Where("ht.id < ?", cursor).OrderBy("ht.id desc")
	}

	if q.AccountAddress != "" {
		sql = sql.
			Join("history_transaction_participants htp USING(transaction_hash)").
			Where("htp.account = ?", q.AccountAddress)
	}

	if q.LedgerSequence != 0 {
		var ledger history.Ledger
		err := Get(ctx, LedgerBySequenceQuery{q.SqlQuery, q.LedgerSequence}, &ledger)

		if err != nil {
			return err
		}

		sql = sql.Where("ht.ledger_sequence = ?", q.LedgerSequence)
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
