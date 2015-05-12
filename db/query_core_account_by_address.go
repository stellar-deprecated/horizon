package db

type CoreAccountByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreAccountByAddressQuery) Get() ([]interface{}, error) {
	sql := CoreAccountRecordSelect.Where("accountid = ?", q.Address).Limit(1)

	var records []CoreAccountRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q CoreAccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
