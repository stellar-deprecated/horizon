package db

type LedgerPageQuery struct {
	SqlQuery
	PageQuery
}

func (q LedgerPageQuery) Get() ([]interface{}, error) {
	sql := LedgerRecordSelect.
		Limit(uint64(q.Limit))

	switch q.Order {
	case "asc":
		sql = sql.Where("hl.id > ?", q.Cursor).OrderBy("hl.id asc")
	case "desc":
		sql = sql.Where("hl.id < ?", q.Cursor).OrderBy("hl.id desc")
	}

	var records []LedgerRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (q LedgerPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
