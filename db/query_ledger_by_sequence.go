package db

type LedgerBySequenceQuery struct {
	SqlQuery
	Sequence int32
}

func (q LedgerBySequenceQuery) Get() ([]interface{}, error) {
	sql := LedgerRecordSelect.Where("sequence = ?", q.Sequence).Limit(1)

	var records []LedgerRecord
	err := q.SqlQuery.Select(sql, &records)
	return makeResult(records), err
}

func (l LedgerBySequenceQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
