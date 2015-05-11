package db

import (
	"errors"
	"math"
	"strconv"
)

const (
	DefaultPageSize = 10
	MaxPageSize     = 200
)

var (
	InvalidOrderError  = errors.New("Invalid order")
	InvalidLimitError  = errors.New("Invalid limit")
	InvalidCursorError = errors.New("Invalid cursor")
)

type PageQuery struct {
	Cursor int64
	Order  string
	Limit  int32
}

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
		err = InvalidOrderError
		return
	}

	// Set cursor
	if cursor != "" {
		var p int64
		p, err = strconv.ParseInt(cursor, 10, 64)

		if err != nil {
			err = InvalidCursorError
			return
		}

		if p < 0 {
			err = InvalidCursorError
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
		err = InvalidLimitError
		return
	case limit > MaxPageSize:
		err = InvalidLimitError
		return
	default:
		result.Limit = limit
	}

	return
}
