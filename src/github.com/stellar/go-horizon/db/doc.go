// Package db provides machinery for the database subsystem of
// horizon.
//
// The crux of this package is `db.Query`.  Various structs implement this
// interface, where the struct usually represent the arguments to the query.
// For example the following would represent a query to find a single account
// by address:
//
//    type AccountByAddress struct {
//      SqlQuery
//      Address string
//    }
//
// You would then implement the query's execution like so:
//
//    func (q CoreAccountByAddressQuery) Select(ctx context.Context, dest interface{}) error {
//    	sql := CoreAccountRecordSelect.Where("accountid = ?", q.Address).Limit(1)
//    	return q.SqlQuery.Select(ctx, sql, dest)
//    }
//
// Executing queries happens through `db.Select()` and `db.Get()`.
//
package db
