package db

import (
	"github.com/jinzhu/gorm"
	"github.com/stellar/go-horizon/test"
	"log"
)

func OpenTestDatabase() gorm.DB {

	result, err := gorm.Open("postgres", test.DatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	result.LogMode(true)
	return result
}

type mockDumpQuery struct{}
type mockStreamedQuery struct{}

func (q mockDumpQuery) Get() ([]interface{}, error) {
	return []interface{}{
		"hello",
		"world",
		"from",
		"go",
	}, nil
}

func (q mockDumpQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= 4
}

type mockQuery struct {
	resultCount int
}

type mockResult struct {
	index int
}

func (q mockQuery) Get() ([]interface{}, error) {
	results := make([]interface{}, q.resultCount)

	for i := 0; i < q.resultCount; i++ {
		results[i] = mockResult{i}
	}

	return results, nil
}

func (q mockQuery) IsComplete(alreadyDelivered int) bool {
	return alreadyDelivered >= q.resultCount
}
