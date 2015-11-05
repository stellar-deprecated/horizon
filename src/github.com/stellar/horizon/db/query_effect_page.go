package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
	"math"
)

// EffectPageQuery is the main query for paging through a collection
// of operations in the history database.
type EffectPageQuery struct {
	SqlQuery
	PageQuery
	Filter SQLFilter
}

// Select executes the query and returns the results
func (q EffectPageQuery) Select(ctx context.Context, dest interface{}) (err error) {
	sql := EffectRecordSelect.
		Limit(uint64(q.Limit)).
		PlaceholderFormat(sq.Dollar).
		RunWith(q.DB)

	op, idx, err := q.CursorInt64Pair(DefaultPairSep)
	if err != nil {
		return
	}

	if idx > math.MaxInt32 {
		idx = math.MaxInt32
	}

	switch q.Order {
	case "asc":
		sql = sql.
			Where(`(
					 heff.history_operation_id > ? 
				OR (
							heff.history_operation_id = ?
					AND heff.order > ?
				))`, op, op, idx).
			OrderBy("heff.history_operation_id asc, heff.order asc")
	case "desc":
		sql = sql.
			Where(`(
					 heff.history_operation_id < ? 
				OR (
							heff.history_operation_id = ?
					AND heff.order < ?
				))`, op, op, idx).
			OrderBy("heff.history_operation_id desc, heff.order desc")
	}

	// apply filter
	if q.Filter != nil {
		sql, err = q.Filter.Apply(ctx, sql)
		if err != nil {
			return
		}
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
