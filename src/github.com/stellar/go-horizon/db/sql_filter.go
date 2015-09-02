package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

// SQLFilter represents an extension mechanism for queries.  A query that wants to provide
// a mechanism to arbitrarily add additional conditions to the sql it uses can accept
// an instance of this interface and call to it to augment the sql it is building.
type SQLFilter interface {
	Apply(context.Context, sq.SelectBuilder) (sq.SelectBuilder, error)
}

// CompositeSQLFilter represents a group of SQLFilters. It implements SQLFilter itself
type CompositeSQLFilter struct {
	Filters []SQLFilter
}

// Apply applies each constituent filter of this composite to the SelectBuilder in order.
func (cf *CompositeSQLFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (res sq.SelectBuilder, err error) {
	res = sql
	for _, f := range cf.Filters {
		res, err = f.Apply(ctx, res)

		if err != nil {
			return
		}
	}

	return
}
