package db

import (
	"errors"
	"math"
	"reflect"
	"strconv"
)

const (
	// DefaultPageSize is the default page size for db queries
	DefaultPageSize = 10
	// MaxPageSize is the max page size for db queries
	MaxPageSize = 200

	// OrderAscending is used to indicate an ascending order in request params
	OrderAscending = "asc"

	// OrderDescending is used to indicate an descending order in request params
	OrderDescending = "desc"
)

var (
	// ErrInvalidOrder is an error that occurs when a user-provided order string
	// is invalid
	ErrInvalidOrder = errors.New("Invalid order")
	// ErrInvalidLimit is an error that occurs when a user-provided limit num
	// is invalid
	ErrInvalidLimit = errors.New("Invalid limit")
	// ErrInvalidCursor is an error that occurs when a user-provided cursor string
	// is invalid
	ErrInvalidCursor = errors.New("Invalid cursor")
	// ErrNotPageable is an error that occurs when the records provided to
	// PageQuery.GetContinuations cannot be cast to Pageable
	ErrNotPageable = errors.New("Records provided are not Pageable")
)

// PageQuery represents a portion of a Query struct concerned with paging
// through a large dataset.
type PageQuery struct {
	Cursor string
	Order  string
	Limit  int32
}

// Invert returns a new PageQuery whose order is reversed
func (p PageQuery) Invert() PageQuery {
	switch p.Order {
	case OrderAscending:
		p.Order = OrderDescending
	case OrderDescending:
		p.Order = OrderAscending
	}

	return p
}

// GetContinuations returns two new PageQuery structs, a next and previous
// query.
func (p PageQuery) GetContinuations(records interface{}) (next PageQuery, prev PageQuery, err error) {
	next = p
	prev = p.Invert()

	rv := reflect.ValueOf(records)
	l := rv.Len()

	if l <= 0 {
		return
	}

	first, ok := rv.Index(0).Interface().(Pageable)
	if !ok {
		err = ErrNotPageable
	}

	last, ok := rv.Index(l - 1).Interface().(Pageable)
	if !ok {
		err = ErrNotPageable
	}

	next.Cursor = last.PagingToken()
	prev.Cursor = first.PagingToken()

	return
}

// CursorInt64 parses this query's Cursor string as an int64
func (p PageQuery) CursorInt64() (int64, error) {
	if p.Cursor == "" {
		switch p.Order {
		case OrderAscending:
			return 0, nil
		case OrderDescending:
			return math.MaxInt64, nil
		default:
			return 0, ErrInvalidOrder
		}
	}

	i, err := strconv.ParseInt(p.Cursor, 10, 64)

	if err != nil {
		return 0, ErrInvalidCursor
	}

	if i < 0 {
		return 0, ErrInvalidCursor
	}

	return i, nil

}

// NewPageQuery creates a new PageQuery struct, ensuring the order, limit, and
// cursor are set to the appropriate defaults and are valid.
func NewPageQuery(
	cursor string,
	order string,
	limit int32,
) (result PageQuery, err error) {

	// Set order
	switch order {
	case "":
		result.Order = OrderAscending
	case OrderAscending, OrderDescending:
		result.Order = order
	default:
		err = ErrInvalidOrder
		return
	}

	result.Cursor = cursor

	// Set limit
	switch {
	case limit == 0:
		result.Limit = DefaultPageSize
	case limit < 0:
		err = ErrInvalidLimit
		return
	case limit > MaxPageSize:
		err = ErrInvalidLimit
		return
	default:
		result.Limit = limit
	}

	return
}
