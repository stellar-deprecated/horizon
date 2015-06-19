package db

import "golang.org/x/net/context"

type TransactionPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress string
	LedgerSequence int32
}

func (q TransactionPageQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := TransactionRecordSelect.
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return nil, err
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
		sql = sql.Where("ht.ledger_sequence = ?", q.LedgerSequence)
	}

	var records []TransactionRecord
	err = q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

func (q TransactionPageQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
