package db

type TransactionByHashQuery struct {
	GormQuery
	Hash string
}

func (q TransactionByHashQuery) Get() ([]interface{}, error) {
	var txs []TransactionRecord

	err := q.GormQuery.DB.
		Where("transaction_hash = ?", q.Hash).
		Find(&txs).
		Error

	if err != nil {
		return nil, err
	}

	results := make([]interface{}, len(txs))
	for i := range txs {
		results[i] = txs[i]
	}

	return results, nil
}

func (q TransactionByHashQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
