package db

type LedgerBySequenceQuery struct {
	GormQuery
	Sequence int32
}

func (l LedgerBySequenceQuery) Get() ([]interface{}, error) {
	var ledgers []LedgerRecord
	err := l.GormQuery.DB.Where("sequence = ?", l.Sequence).Find(&ledgers).Error

	if err != nil {
		return nil, err
	}

	results := make([]interface{}, len(ledgers))
	for i := range ledgers {
		results[i] = ledgers[i]
	}

	return results, nil
}

func (l LedgerBySequenceQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
