package db

type AccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q AccountByAddressQuery) Get() ([]interface{}, error) {
	sql := AccountRecordSelect.Where("address = ?", q.Address).Limit(1)

	var records []AccountRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q AccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
