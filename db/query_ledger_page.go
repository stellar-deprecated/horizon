package db

import (
	"errors"
	"github.com/jinzhu/gorm"
)

type LedgerPageQuery struct {
	GormQuery
	Cursor int64
	Order  string
	Limit  int32
}

func (l LedgerPageQuery) Get() (results []interface{}, err error) {
	var ledgers []LedgerRecord
	var baseScope *gorm.DB

	switch l.Order {
	case "asc":
		baseScope = l.GormQuery.DB.Where("id > ?", l.Cursor).Order("id asc")
	case "desc":
		baseScope = l.GormQuery.DB.Where("id < ?", l.Cursor).Order("id desc")
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

func (l LedgerPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(l.Limit)
}
