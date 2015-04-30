// This package provides machinery for the database subsystem of
// horizon.
//
// The crux of this package is `db.Query`.  Various structs implement this
// interface, where the struct usually represent the arguments to the query.
// For example the following would represent a query to find a single account
// by address:
//
//    type AccountByAddress struct {
//      GormQuery
//      Address string
//    }
//
// You would then implement the query's execution like so:
//
//    func (q AccountByAddress) Get() []interface{} {
//      var account Account
//      err := q.GormQuery.DB.Where("address = ?", q.Address).First(&account).Error
//      if err != nil {
//        return nil, err
//      }
//
//      return []interface{}{account}, nil
//    }
//
// Executing queries happens through `db.Results()`, `db.First()`, and
// `db.Stream()`.
//
package db
