package db

import (
	sq "github.com/lann/squirrel"
)

type TransactionPageQuery struct {
	GormQuery
	PageQuery
	AccountAddress string
	LedgerSequence int32
}

func (q TransactionPageQuery) Get() (results []interface{}, err error) {
	sql := TransactionRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB.DB())

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

	rows, err := sql.Query()
	if err != nil {
		return
	}

	defer rows.Close()

	results = []interface{}{}
	for rows.Next() {
		record := &TransactionRecord{}
		err = record.ScanFrom(rows)

		if err != nil {
			return
		}

		results = append(results, *record)
	}

	return
}

func (q TransactionPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
