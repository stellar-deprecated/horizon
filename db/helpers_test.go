package db

import (
	"database/sql"
	"fmt"
	"log"
	"math"
	"reflect"

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
	rv := reflect.ValueOf(actual)
	t := options[0].(func(interface{}) int64)

	prev := int64(0)

	for i := 0; i < rv.Len(); i++ {
		r := rv.Index(i).Interface()
		cur := t(r)

		if cur <= prev {
			return fmt.Sprintf("not ordered ascending: idx:%s has order %d, which is less than the previous:%d", i, cur, prev)
		}

		prev = cur
	}

	return ""
}

func ShouldBeOrderedDescending(actual interface{}, options ...interface{}) string {
	rv := reflect.ValueOf(actual)

	t := options[0].(func(interface{}) int64)

	prev := int64(math.MaxInt64)

	for i := 0; i < rv.Len(); i++ {
		r := rv.Index(i).Interface()
		cur := t(r)

		if cur >= prev {
			return fmt.Sprintf("not ordered descending: idx:%d has order %d, which is more than the previous:%d", i, cur, prev)
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

// Mock Query

type mockQuery struct {
	resultCount int
}

type mockResult struct {
	index int
}

func (q mockQuery) Select(ctx context.Context, dest interface{}) error {
	results := make([]mockResult, q.resultCount)

	for i := 0; i < q.resultCount; i++ {
		results[i] = mockResult{i}
	}

	return setOn(results, dest)
}

// BrokenQuery is a helper for tests that always returns an error
type BrokenQuery struct {
	Err error
}

func (q BrokenQuery) Select(ctx context.Context, dest interface{}) error {
	return q.Err
}
