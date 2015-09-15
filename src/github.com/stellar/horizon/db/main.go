package db

import (
	"database/sql"
	stderr "errors"
	"fmt"
	"reflect"

	"golang.org/x/net/context"

	"github.com/go-errors/errors"
	_ "github.com/lib/pq" // allow postgres sql connections
)

// ErrDestinationNotPointer is returned when the result destination for a query
// is not a pointer
var ErrDestinationNotPointer = errors.New("dest is not a pointer")

// ErrDestinationNotSlice is returned when the derefed destination is not
// a slice
var ErrDestinationNotSlice = errors.New("dest is not a slice")

// ErrDestinationNotSlice is returned when the destination is nil
var ErrDestinationNil = errors.New("dest is nil")

// ErrDestinationIncompatible is returned when one of the retrieved results is
// not capable of being assigned to the destination
var ErrDestinationIncompatible = errors.New("Retrieved results' type is not compatible with dest")

// ErrNoResults is returned when no results are found during a `Get` call
// NOTE: this is not a go-errors based error, as stack traces are unnecessary
var ErrNoResults = stderr.New("No record found")

// Query is the interface to implement to plug a struct into the query system.
// see doc.go for an example.
type Query interface {
	Select(context.Context, interface{}) error
}

// Pageable records have a defined order, and the place withing that order
// is determined by the paging token
type Pageable interface {
	PagingToken() string
}

type Record interface{}

type HistoryRecord struct {
	Id int64 `db:"id"`
}

func (r HistoryRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}

// Open the postgres database at the provided url and performing an initial
// ping to ensure we can connect to it.
func Open(url string) (*sql.DB, error) {
	db, err := sql.Open("postgres", url)
	if err != nil {
		return db, errors.Wrap(err, 1)
	}

	err = db.Ping()
	if err != nil {
		return db, errors.Wrap(err, 1)
	}

	return db, nil
}

// Select runs the provided query, setting all found results on dest.
func Select(ctx context.Context, query Query, dest interface{}) error {
	if err := validateDestination(dest); err != nil {
		return err
	}

	dvp := reflect.ValueOf(dest)
	dv := reflect.Indirect(dvp)
	// create an intermediary slice of the same type
	rvp := reflect.New(dv.Type())
	rv := reflect.Indirect(rvp)

	if dv.Kind() != reflect.Slice {
		return errors.New(ErrDestinationNotSlice)
	}

	err := query.Select(ctx, rvp.Interface())

	if err != nil {
		return err
	}

	dv.Set(rv)
	return nil
}

// MustSelect is like Select, but panics on error
func MustSelect(ctx context.Context, query Query, dest interface{}) {
	err := Select(ctx, query, dest)

	if err != nil {
		panic(err)
	}
}

// Get runs the provided query, returning the first result found, if any.
func Get(ctx context.Context, query Query, dest interface{}) error {
	if err := validateDestination(dest); err != nil {
		return err
	}

	dvp := reflect.ValueOf(dest)
	dv := reflect.Indirect(dvp)

	// create a slice of the same type as dest
	sliceType := reflect.SliceOf(dv.Type())
	rvp := reflect.New(sliceType)
	rv := reflect.Indirect(rvp)

	err := query.Select(ctx, rvp.Interface())
	if err != nil {
		return err
	}

	if rv.Len() == 0 {
		return ErrNoResults
	}

	// set the first result to the destination
	dv.Set(rv.Index(0))
	return nil
}

// MustGet is like Get, but panics on error
func MustGet(ctx context.Context, query Query, dest interface{}) {
	err := Get(ctx, query, dest)

	if err != nil {
		panic(err)
	}
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

func setOn(src interface{}, dest interface{}) error {
	if dest == nil {
		return errors.New(ErrDestinationNil)
	}

	rv := reflect.ValueOf(src)
	dvp := reflect.ValueOf(dest)

	if dvp.Kind() != reflect.Ptr {
		return errors.New(ErrDestinationNotPointer)
	}

	dv := reflect.Indirect(dvp)
	if !rv.Type().AssignableTo(dv.Type()) {
		return errors.New(ErrDestinationIncompatible)
	}

	dv.Set(rv)
	return nil
}

func validateDestination(dest interface{}) error {
	if dest == nil {
		return errors.New(ErrDestinationNil)
	}

	dvp := reflect.ValueOf(dest)

	if dvp.Kind() != reflect.Ptr {
		return errors.New(ErrDestinationNotPointer)
	}

	return nil
}

func FilterAll(filters ...SQLFilter) *CompositeSQLFilter {
	return &CompositeSQLFilter{filters}

}
