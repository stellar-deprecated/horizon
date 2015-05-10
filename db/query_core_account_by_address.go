package db

type CoreAccountByAddressQuery struct {
	GormQuery
	Address string
}

func (q CoreAccountByAddressQuery) Get() ([]interface{}, error) {
	var account CoreAccountRecord
	err := q.GormQuery.DB.Where("accountid = ?", q.Address).First(&account).Error
	return []interface{}{account}, err
}

func (q CoreAccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
