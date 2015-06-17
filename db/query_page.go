package db

import (
	"errors"
	"math"
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
)

// PageQuery represents a portion of a Query struct concerned with paging
// through a large dataset.
type PageQuery struct {
	Cursor int64
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
		result.Order = "asc"
	case "asc", "desc":
		result.Order = order
	default:
		err = ErrInvalidOrder
		return
	}

	// Set cursor
	if cursor != "" {
		var p int64
		p, err = strconv.ParseInt(cursor, 10, 64)

		if err != nil {
			err = ErrInvalidCursor
			return
		}

		if p < 0 {
			err = ErrInvalidCursor
			return
		}

		result.Cursor = p
	} else {
		if result.Order == "desc" {
			result.Cursor = math.MaxInt64
		}
	}

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
