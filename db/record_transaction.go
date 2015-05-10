package db

import (
	"fmt"
	"time"
)

type TransactionRecord struct {
	Id               int64
	TransactionHash  string
	LedgerSequence   int32
	ApplicationOrder int32
	Account          string
	AccountSequence  int64
	MaxFee           int32
	FeePaid          int32
	OperationCount   int32
	ClosedAt         time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

func (r TransactionRecord) TableName() string {
	return "history_transactions"
}

func (r TransactionRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
