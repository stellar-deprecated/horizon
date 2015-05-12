package db

type TransactionPageQuery struct {
	SqlQuery
	PageQuery
	AccountAddress string
	LedgerSequence int32
}

func (q TransactionPageQuery) Get() ([]interface{}, error) {
	sql := TransactionRecordSelect.
		Limit(uint64(q.Limit))

	switch q.Order {
	case "asc":
		sql = sql.Where("ht.id > ?", q.Cursor).OrderBy("ht.id asc")
	case "desc":
		sql = sql.Where("ht.id < ?", q.Cursor).OrderBy("ht.id desc")
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
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q TransactionPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
