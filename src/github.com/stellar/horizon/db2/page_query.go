package db2

import (
	"fmt"
	"math"
	"reflect"
	"strconv"
	"strings"

	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
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

	// DefaultPairSep is the default separator used to separate two numbers for CursorInt64Pair
	DefaultPairSep = "-"
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

// ApplyTo returns a new SelectBuilder after applying the paging effects of
// `p` to `sql`.  This method provides the default case for paging: int64
// cursor-based paging by an id column.
func (p PageQuery) ApplyTo(
	sql sq.SelectBuilder,
	col string,
) (sq.SelectBuilder, error) {
	sql = sql.Limit(p.Limit)

	cursor, err := p.CursorInt64()
	if err != nil {
		return sql, err
	}

	switch p.Order {
	case "asc":
		sql = sql.
			Where(fmt.Sprintf("%s > ?", col), cursor).
			OrderBy(fmt.Sprintf("%s asc", col))
	case "desc":
		sql = sql.
			Where(fmt.Sprintf("%s < ?", col), cursor).
			OrderBy(fmt.Sprintf("%s desc", col))
	default:
		return sql, errors.Errorf("invalid order: %s", p.Order)
	}

	return sql, nil
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
		err = errors.New(ErrNotPageable)
	}

	last, ok := rv.Index(l - 1).Interface().(Pageable)
	if !ok {
		err = errors.New(ErrNotPageable)
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
			return 0, errors.New(ErrInvalidOrder)
		}
	}

	i, err := strconv.ParseInt(p.Cursor, 10, 64)

	if err != nil {
		return 0, errors.New(ErrInvalidCursor)
	}

	if i < 0 {
		return 0, errors.New(ErrInvalidCursor)
	}

	return i, nil

}

// CursorInt64Pair parses this query's Cursor string as two int64s, separated by the provided separator
func (p PageQuery) CursorInt64Pair(sep string) (l int64, r int64, err error) {

	if p.Cursor == "" {
		switch p.Order {
		case OrderAscending:
			l = 0
			r = 0
		case OrderDescending:
			l = math.MaxInt64
			r = math.MaxInt64
		default:
			err = errors.New(ErrInvalidOrder)
		}
		return
	}

	parts := strings.SplitN(p.Cursor, sep, 2)

	// In the event that the cursor is only a single number
	// we use maxInt as the second element.  This ensures that
	// cursors containing a single element skip past all entries
	// specified by the first element.
	//
	// As an example, this behavior ensures that an effect cursor
	// specified using only a ledger sequence will properly exclude
	// all effects originated in the sequence provided.
	if len(parts) != 2 {
		parts = append(parts, fmt.Sprintf("%d", math.MaxInt64))
	}

	l, err = strconv.ParseInt(parts[0], 10, 64)
	if err != nil {
		err = errors.Wrap(err, 1)
		return
	}

	r, err = strconv.ParseInt(parts[1], 10, 64)
	if err != nil {
		err = errors.Wrap(err, 1)
		return
	}

	if l < 0 || r < 0 {
		err = errors.New(ErrInvalidCursor)
	}

	return
}

// NewPageQuery creates a new PageQuery struct, ensuring the order, limit, and
// cursor are set to the appropriate defaults and are valid.
func NewPageQuery(
	cursor string,
	order string,
	limit uint64,
) (result PageQuery, err error) {

	// Set order
	switch order {
	case "":
		result.Order = OrderAscending
	case OrderAscending, OrderDescending:
		result.Order = order
	default:
		err = errors.New(ErrInvalidOrder)
		return
	}

	result.Cursor = cursor

	// Set limit
	switch {
	case limit == 0:
		result.Limit = DefaultPageSize
	case limit < 0:
		err = errors.New(ErrInvalidLimit)
		return
	case limit > MaxPageSize:
		err = errors.New(ErrInvalidLimit)
		return
	default:
		result.Limit = limit
	}

	return
}

// MustPageQuery behaves as NewPageQuery, but panics upon error
func MustPageQuery(cursor string, order string, limit uint64) PageQuery {
	r, err := NewPageQuery(cursor, order, limit)
	if err != nil {
		panic(err)
	}

	return r
}
