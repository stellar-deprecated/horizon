package db

import (
	"github.com/jinzhu/gorm"
	_ "github.com/lib/pq"
)

type GormQuery struct {
	DB *gorm.DB
}

type Query interface {
	Get() ([]interface{}, error)
	IsComplete(int) bool
}

type Pageable interface {
	PagingToken() interface{}
}

// Open the postgres database at the provided url and performing an initial
// ping to ensure we can connect to it.
func Open(url string) (gorm.DB, error) {
	db, err := gorm.Open("postgres", url)

	if err != nil {
		return db, err
	}

	err = db.DB().Ping()

	if err != nil {
		return db, err
	}

	return db, nil
}

// Runs the provided query, returning all found results
func Results(query Query) ([]interface{}, error) {
	return query.Get()
}

// Runs the provided query, returning the first result if found,
// otherwise nil
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
