package db

import (
	"time"
)

type LedgerRecord struct {
	Id                 int64
	Sequence           int32
	LedgerHash         string
	PreviousLedgerHash string
	TransactionCount   int32
	OperationCount     int32
	ClosedAt           time.Time
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

func (lr LedgerRecord) TableName() string {
	return "history_ledgers"
}

func (lr LedgerRecord) PagingToken() interface{} {
	return lr.Id
}
