package db

// A row of data from the `accounts` table from stellar-core
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
