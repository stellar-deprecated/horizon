package db

import (
	"github.com/jinzhu/gorm"
	"time"
)

type LedgerRecord struct {
	ID                 int32
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

type LedgerBySequenceQuery struct {
	Sequence int32
}

func (l LedgerBySequenceQuery) Run(db gorm.DB) ([]interface{}, error) {
	var ledgers []LedgerRecord
	err := db.Where("sequence = ?", l.Sequence).Find(&ledgers).Error

	if err != nil {
		return nil, err
	}

	results := make([]interface{}, len(ledgers))
	for i := range ledgers {
		results[i] = ledgers[i]
	}

	return results, nil
}
