package db

type CoreAccountRecord struct {
	Accountid     string
	Balance       int64
	Seqnum        int64
	Numsubentries int32
	Inflationdest string
	Thresholds    string
	Flags         int32
}

func (r CoreAccountRecord) TableName() string {
	return "accounts"
}

type AccountByAddressQuery struct {
	GormQuery
	Address string
}

func (q AccountByAddressQuery) Get() ([]interface{}, error) {
	var account CoreAccountRecord
	err := q.GormQuery.DB.Where("accountid = ?", q.Address).First(&account).Error
	return []interface{}{account}, err
}

func (q AccountByAddressQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
