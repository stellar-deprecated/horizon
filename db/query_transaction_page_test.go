package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"math"
	"testing"
)

func TestTransactionPageQuery(t *testing.T) {
	Convey("TransactionPageQuery", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()
		makeQuery := func(c string, o string, l int32) TransactionPageQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return TransactionPageQuery{
				GormQuery{&db},
				pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			records, _ := Results(makeQuery("", "asc", 0))
			cur := int64(0)

			for _, r := range records {
				So(r, ShouldHaveSameTypeAs, TransactionRecord{})
				id := r.(TransactionRecord).Id
				So(id, ShouldBeGreaterThan, cur)
				cur = id
			}

			// desc orders descending by id
			records, _ = Results(makeQuery("", "desc", 0))
			cur = math.MaxInt64

			for _, r := range records {
				So(r, ShouldHaveSameTypeAs, TransactionRecord{})
				id := r.(TransactionRecord).Id
				So(id, ShouldBeLessThan, cur)
				cur = id
			}
		})

		Convey("limits properly", func() {
			// returns number specified
			records, _ := Results(makeQuery("", "asc", 3))
			So(len(records), ShouldEqual, 3)

			// returns all rows if limit is higher
			records, _ = Results(makeQuery("", "asc", 10))
			So(len(records), ShouldEqual, 4)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record, _ := First(makeQuery("", "asc", 0))
			So(record.(TransactionRecord).Id, ShouldEqual, 12884905984)

			// highest id if ordered descending and no cursor
			record, _ = First(makeQuery("", "desc", 0))
			So(record.(TransactionRecord).Id, ShouldEqual, 17179873280)

			// starts after the cursor if ordered ascending
			record, _ = First(makeQuery("12884905984", "asc", 0))
			So(record.(TransactionRecord).Id, ShouldEqual, 12884910080)

			// starts before the cursor if ordered descending
			record, _ = First(makeQuery("17179873280", "desc", 0))
			So(record.(TransactionRecord).Id, ShouldEqual, 12884914176)
		})
	})
}
