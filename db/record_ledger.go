package db

import (
	"fmt"
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

func (r LedgerRecord) TableName() string {
	return "history_ledgers"
}

func (r LedgerRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
