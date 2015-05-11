package db

import (
	"github.com/jinzhu/gorm"
)

type LedgerPageQuery struct {
	GormQuery
	PageQuery
}

func (q LedgerPageQuery) Get() (results []interface{}, err error) {
	var records []LedgerRecord
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

func (q LedgerPageQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
