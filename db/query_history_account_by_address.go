package db

type HistoryAccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q HistoryAccountByAddressQuery) Get() ([]interface{}, error) {
	sql := HistoryAccountRecordSelect.Where("address = ?", q.Address).Limit(1)

	var records []HistoryAccountRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q HistoryAccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
