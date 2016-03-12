package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/test"
)

func TestHistoryPageQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("HistoryAccountPageQuery", t, func() {
		var records []history.Account

		makeQuery := func(c string, o string, l int32) HistoryAccountPageQuery {
			pq, err := db2.NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return HistoryAccountPageQuery{
				SqlQuery:  SqlQuery{horizonDb},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			MustSelect(ctx, makeQuery("", "asc", 0), &records)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Account{})
				return r.(history.Account).ID
			})

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0), &records)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Account{})
				return r.(history.Account).ID
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			MustSelect(ctx, makeQuery("", "asc", 2), &records)
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			MustSelect(ctx, makeQuery("", "asc", 10), &records)
			So(len(records), ShouldEqual, 4)
		})

		Convey("cursor works properly", func() {
			var record history.Account

			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0), &record)
			So(record.ID, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0), &record)
			So(record.ID, ShouldEqual, 8589946881)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("8589938689", "asc", 0), &record)
			So(record.ID, ShouldEqual, 8589942785)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("8589946881", "desc", 0), &record)
			So(record.ID, ShouldEqual, 8589942785)
		})

	})
}
