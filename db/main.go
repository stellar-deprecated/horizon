package db

import (
	"database/sql"
	"errors"
	"reflect"

	"golang.org/x/net/context"

	_ "github.com/lib/pq" // allow postgres sql connections
	"github.com/rcrowley/go-metrics"
)

var ErrDestinationNotPointer = errors.New("dest is not a pointer")
var ErrDestinationNotSlice = errors.New("dest is not a slice")
var ErrDestinationNil = errors.New("dest is nil")
var ErrDestinationIncompatible = errors.New("Retrieved results' type is not compatible with dest")

type Query interface {
	Get(context.Context) ([]interface{}, error)
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
func Results(ctx context.Context, query Query) ([]interface{}, error) {
	return query.Get(ctx)
}

// Select runs the provided query, appending all results into dest.  Dest must
// be a pointer to a slice of a type compatible with the records returned from
// the query.
//
// NOTE:  At present this method is much more expensive than it should be
// because it does a lot of casting and reflection throughout its call graph (
// any given record ends up going from Record to interface{} and back again at
// least once, unnecessarily). this current implementation is a stopgap on the
// way to removing the Results() and First() functions, which return interface{}
// values.  We cannot yet remove those due to how intertwined they are with the
// SSE system.
func Select(ctx context.Context, query Query, dest interface{}) error {
	records, err := Results(ctx, query)

	if err != nil {
		return err
	}

	if dest == nil {
		return ErrDestinationNil
	}

	dvp := reflect.ValueOf(dest)

	if dvp.Kind() != reflect.Ptr {
		return ErrDestinationNotPointer
	}

	dv := reflect.Indirect(dvp)

	if dv.Kind() != reflect.Slice {
		return ErrDestinationNotSlice
	}

	rvp := reflect.New(dv.Type())
	rv := reflect.Indirect(rvp)
	slicet := dv.Type().Elem()

	for _, record := range records {
		recordv := reflect.ValueOf(record)

		if !recordv.Type().AssignableTo(slicet) {
			return ErrDestinationIncompatible
		}

		rv = reflect.Append(rv, recordv)
	}

	dv.Set(rv)
	return nil
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

func MustResults(ctx context.Context, q Query) []interface{} {
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
func makeResult(src interface{}) []interface{} {
	srcValue := reflect.ValueOf(src)
	srcLen := srcValue.Len()
	result := make([]interface{}, srcLen)

	for i := 0; i < srcLen; i++ {
		result[i] = srcValue.Index(i).Interface()
	}
	return result
}
