package db

import (
	sq "github.com/lann/squirrel"
)

type TransactionByHashQuery struct {
	SqlQuery
	Hash string
}

func (q TransactionByHashQuery) Get() (results []interface{}, err error) {
	rows, err := TransactionRecordSelect.
		Limit(1).
		Where("transaction_hash = ?", q.Hash).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB).
		Query()

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

func (q TransactionByHashQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
