package db

type TransactionByHashQuery struct {
	SqlQuery
	Hash string
}

func (q TransactionByHashQuery) Get() ([]interface{}, error) {
	sql := TransactionRecordSelect.
		Limit(1).
		Where("transaction_hash = ?", q.Hash)

	var records []TransactionRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q TransactionByHashQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
