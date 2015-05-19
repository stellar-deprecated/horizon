package db

import (
	"database/sql"
	"fmt"
	"log"
	"math"

	"github.com/stellar/go-horizon/test"
	"golang.org/x/net/context"
)

func OpenTestDatabase() *sql.DB {

	result, err := sql.Open("postgres", test.DatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	return result
}

func OpenStellarCoreTestDatabase() *sql.DB {

	result, err := sql.Open("postgres", test.StellarCoreDatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	return result
}

func ShouldBeOrderedAscending(actual interface{}, options ...interface{}) string {
	records := actual.([]interface{})
	t := options[0].(func(interface{}) int64)

	prev := int64(0)

	for i, r := range records {
		cur := t(r)

		if cur <= prev {
			return fmt.Sprintf("not ordered ascending: idx:%s has order %d, which is less than the previous:%d", i, cur, prev)
		}

		prev = cur
	}

	return ""
}

func ShouldBeOrderedDescending(actual interface{}, options ...interface{}) string {
	records := actual.([]interface{})
	t := options[0].(func(interface{}) int64)

	prev := int64(math.MaxInt64)

	for i, r := range records {
		cur := t(r)

		if cur >= prev {
			return fmt.Sprintf("not ordered decending: idx:%s has order %d, which is more than the previous:%d", i, cur, prev)
		}

		prev = cur
	}

	return ""
}

// Mock Dump Query

type mockDumpQuery struct{}

func (q mockDumpQuery) Get(ctx context.Context) ([]interface{}, error) {
	return []interface{}{
		"hello",
		"world",
		"from",
		"go",
	}, nil
}

func (q mockDumpQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= 4
}

// Mock Query

type mockQuery struct {
	resultCount int
}

type mockResult struct {
	index int
}

func (q mockQuery) Get(ctx context.Context) ([]interface{}, error) {
	results := make([]interface{}, q.resultCount)

	for i := 0; i < q.resultCount; i++ {
		results[i] = mockResult{i}
	}

	return results, nil
}

func (q mockQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= q.resultCount
}

// Broken Query

type BrokenQuery struct {
	Err error
}

func (q BrokenQuery) Get(ctx context.Context) ([]interface{}, error) {
	return nil, q.Err
}

func (q BrokenQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered > 0
}
