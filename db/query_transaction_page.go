package db

import (
	"github.com/jinzhu/gorm"
)

type TransactionPageQuery struct {
	GormQuery
	PageQuery
}

func (q TransactionPageQuery) Get() (results []interface{}, err error) {
	var records []TransactionRecord
	var baseScope *gorm.DB

	switch q.Order {
	case "asc":
		baseScope = q.GormQuery.DB.Where("id > ?", q.Cursor).Order("id asc")
	case "desc":
		baseScope = q.GormQuery.DB.Where("id < ?", q.Cursor).Order("id desc")
	}

	err = baseScope.Limit(q.Limit).Find(&records).Error

	if err != nil {
		return
	}

	results = make([]interface{}, len(records))
	for i := range records {
		results[i] = records[i]
	}

	return
}

func (q TransactionPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
