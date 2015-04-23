package db

import (
	"github.com/jinzhu/gorm"
)

type Query interface {
	Run(db gorm.DB) ([]interface{}, error)
}

type Pageable interface {
	PagingToken() interface{}
}
