package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestHistoryPageQuery(t *testing.T) {
	test.LoadScenario("base")
	db := OpenTestDatabase()
	defer db.Close()

	Convey("HistoryAccountPageQuery", t, func() {
		makeQuery := func(c string, o string, l int32) HistoryAccountPageQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return HistoryAccountPageQuery{
				SqlQuery:  SqlQuery{db},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			records := MustResults(makeQuery("", "asc", 0))

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, HistoryAccountRecord{})
				return r.(HistoryAccountRecord).Id
			})

			// desc orders descending by id
			records = MustResults(makeQuery("", "desc", 0))

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, HistoryAccountRecord{})
				return r.(HistoryAccountRecord).Id
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			records := MustResults(makeQuery("", "asc", 2))
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			records = MustResults(makeQuery("", "asc", 10))
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record := MustFirst(makeQuery("", "asc", 0))
			So(record.(HistoryAccountRecord).Id, ShouldEqual, 12884905984)

			// highest id if ordered descending and no cursor
			record = MustFirst(makeQuery("", "desc", 0))
			So(record.(HistoryAccountRecord).Id, ShouldEqual, 12884914176)

			// starts after the cursor if ordered ascending
			record = MustFirst(makeQuery("12884905984", "asc", 0))
			So(record.(HistoryAccountRecord).Id, ShouldEqual, 12884910080)

			// starts before the cursor if ordered descending
			record = MustFirst(makeQuery("12884914176", "desc", 0))
			So(record.(HistoryAccountRecord).Id, ShouldEqual, 12884910080)
		})

	})
}
