package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/test"
)

func TestTransactionPageQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("TransactionPageQuery", t, func() {
		var records []history.Transaction

		makeQuery := func(c string, o string, l int32) TransactionPageQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return TransactionPageQuery{
				SqlQuery:  SqlQuery{horizonDb},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			MustSelect(ctx, makeQuery("", "asc", 0), &records)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Transaction{})
				return r.(history.Transaction).ID
			})

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0), &records)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Transaction{})
				return r.(history.Transaction).ID
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			MustSelect(ctx, makeQuery("", "asc", 3), &records)
			So(len(records), ShouldEqual, 3)

			// returns all rows if limit is higher
			MustSelect(ctx, makeQuery("", "asc", 10), &records)
			So(len(records), ShouldEqual, 4)
		})

		Convey("cursor works properly", func() {
			var record history.Transaction

			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0), &record)
			So(record.ID, ShouldEqual, 8589938688)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0), &record)
			So(record.ID, ShouldEqual, 12884905984)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("8589938688", "asc", 0), &record)
			So(record.ID, ShouldEqual, 8589942784)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("12884905984", "desc", 0), &record)
			So(record.ID, ShouldEqual, 8589946880)
		})

		Convey("restricts to address properly", func() {
			address := "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"
			q := makeQuery("", "asc", 0)
			q.AccountAddress = address
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				So(r.Account, ShouldEqual, address)
			}
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.LedgerSequence = 3
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 1)

			for _, r := range records {
				So(r.LedgerSequence, ShouldEqual, q.LedgerSequence)
			}
		})
	})
}
