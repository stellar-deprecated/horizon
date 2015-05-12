// This package provides machinery for the database subsystem of
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
//    func (q CoreAccountByAddressQuery) Get() ([]interface{}, error) {
//      sql := CoreAccountRecordSelect.Where("accountid = ?", q.Address).Limit(1)
//
//      var records []CoreAccountRecord
//      err := q.SqlQuery.Select(sql, &records)
//      return makeResult(records), err
//    }
//
// Executing queries happens through `db.Results()`, `db.First()`, and
// `db.Stream()`.
//
package db
