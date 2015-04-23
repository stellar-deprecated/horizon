package db

import (
	"errors"
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

func (lr LedgerRecord) PagingToken() interface{} {
	return lr.Sequence
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

type LedgerPageQuery struct {
	After int32
	Order string
	Limit int32
}

func (l LedgerPageQuery) Run(db gorm.DB) (results []interface{}, err error) {
	var ledgers []LedgerRecord
	var baseScope *gorm.DB

	switch l.Order {
	case "asc":
		baseScope = db.Where("sequence > ?", l.After).Order("sequence asc")
	case "desc":
		baseScope = db.Where("sequence < ?", l.After).Order("sequence desc")
	default:
		err = errors.New("Invalid sort: " + l.Order)
		return
	}

	err = baseScope.Limit(l.Limit).Find(&ledgers).Error

	if err != nil {
		return
	}

	results = make([]interface{}, len(ledgers))
	for i := range ledgers {
		results[i] = ledgers[i]
	}

	return
}
