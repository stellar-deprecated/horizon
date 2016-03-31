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
		var account history.Account

		err := q.HistoryQ(ctx).AccountByAddress(&account, q.AccountAddress)
		if err != nil {
			return err
		}

		sql = sql.
			Join("history_transaction_participants htp ON htp.history_transaction_id = ht.id").
			Where("htp.history_account_id = ?", account.ID)
	}

	if q.LedgerSequence != 0 {
		var ledger history.Ledger

		err := q.HistoryQ(ctx).LedgerBySequence(&ledger, q.LedgerSequence)
		if err != nil {
			return err
		}

		sql = sql.Where("ht.ledger_sequence = ?", q.LedgerSequence)
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
