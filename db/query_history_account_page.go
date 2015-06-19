package db

import "golang.org/x/net/context"

// HistoryAccountPageQuery queries for a single page of HitoryAccount objects,
// in the normal collection paging style
type HistoryAccountPageQuery struct {
	SqlQuery
	PageQuery
}

// Get executes the query, returning any results
func (q HistoryAccountPageQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := HistoryAccountRecordSelect.
		Limit(uint64(q.Limit))

	cursor, err := q.CursorInt64()
	if err != nil {
		return nil, err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("ha.id > ?", cursor).OrderBy("ha.id asc")
	case "desc":
		sql = sql.Where("ha.id < ?", cursor).OrderBy("ha.id desc")
	}

	var records []HistoryAccountRecord
	err = q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err
}

// IsComplete returns true if the query considers itself complete.  In this case,
// the query will consider itself complete when it has delivered it's
// limit
func (q HistoryAccountPageQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
