package db

import (
	"github.com/jinzhu/gorm"
)

type GormQuery struct {
	DB *gorm.DB
}

type Query interface {
	Get() ([]interface{}, error)
}

type Pageable interface {
	PagingToken() interface{}
}

func Results(query Query) ([]interface{}, error) {
	return query.Get()
}

func First(query Query) (interface{}, error) {
	res, err := query.Get()

	if err != nil {
		return nil, err
	}

	if len(res) == 0 {
		return nil, nil
	} else {
		return res[0], nil
	}
}
