package db

type CoreTrustlinesByAddressQuery struct {
	SqlQuery
	Address string
}

func (q CoreTrustlinesByAddressQuery) Get() ([]interface{}, error) {
	sql := CoreTrustlineRecordSelect.Where("accountid = ?", q.Address)

	var records []CoreTrustlineRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q CoreTrustlinesByAddressQuery) IsComplete(alreadyDelivered int) bool {
	// this query is not stream compatible.  If we've returned any results
	// consider the query complete
	return alreadyDelivered > 0
}
