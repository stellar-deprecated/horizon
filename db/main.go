package db

import (
	"database/sql"
	"errors"
	"reflect"

	"golang.org/x/net/context"

	_ "github.com/lib/pq" // allow postgres sql connections
	"github.com/rcrowley/go-metrics"
)

type Query interface {
	Get(context.Context) ([]Record, error)
	IsComplete(context.Context, int) bool
}

type Pageable interface {
	PagingToken() string
}

type Record interface{}

// Open the postgres database at the provided url and performing an initial
// ping to ensure we can connect to it.
func Open(url string) (*sql.DB, error) {

	db, err := sql.Open("postgres", url)

	if err != nil {
		return db, err
	}

	err = db.Ping()

	if err != nil {
		return db, err
	}

	return db, nil
}

// Results runs the provided query, returning all found results
func Results(ctx context.Context, query Query) ([]Record, error) {
	return query.Get(ctx)
}

// First runs the provided query, returning the first result if found,
// otherwise nil
func First(ctx context.Context, query Query) (interface{}, error) {
	res, err := query.Get(ctx)

	switch {
	case err != nil:
		return nil, err
	case len(res) == 0:
		return nil, nil
	default:
		return res[0], nil
	}
}

func MustFirst(ctx context.Context, q Query) interface{} {
	result, err := First(ctx, q)

	if err != nil {
		panic(err)
	}

	return result
}

func MustResults(ctx context.Context, q Query) []Record {
	result, err := Results(ctx, q)

	if err != nil {
		panic(err)
	}

	return result
}

func QueryGauge() metrics.Gauge {
	return globalStreamManager.queryGauge
}

// helper method suited to confirm query validity.  checkOptions ensures
// that zero or one of the provided bools ares true, but will return an error
// if more than one clause is true.
func checkOptions(clauses ...bool) error {
	hasOneSet := false

	for _, isSet := range clauses {
		if !isSet {
			continue
		}

		if hasOneSet {
			return errors.New("Invalid options: multiple are set")
		}

		hasOneSet = true
	}

	return nil
}

// Converts a typed slice to a slice of interface{}, suitable
// for return through the Get() method of Query
func makeResult(src interface{}) []Record {
	srcValue := reflect.ValueOf(src)
	srcLen := srcValue.Len()
	result := make([]Record, srcLen)

	for i := 0; i < srcLen; i++ {
		result[i] = srcValue.Index(i).Interface()
	}
	return result
}
