package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/test"
	"github.com/stellar/horizon/toid"
)

func TestOperationPageQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("OperationPageQuery", t, func() {
		var records []history.Operation

		makeQuery := func(c string, o string, l int32) OperationPageQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return OperationPageQuery{
				SqlQuery:  SqlQuery{horizonDb},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			MustSelect(ctx, makeQuery("", "asc", 0), &records)
			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Operation{})
				return r.(history.Operation).ID
			})

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0), &records)
			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, history.Operation{})
				return r.(history.Operation).ID
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
			var record history.Operation

			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0), &record)
			So(record.ID, ShouldEqual, 8589938689)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0), &record)
			So(record.ID, ShouldEqual, 12884905985)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("8589938689", "asc", 0), &record)
			So(record.ID, ShouldEqual, 8589942785)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("12884905985", "desc", 0), &record)
			So(record.ID, ShouldEqual, 8589946881)
		})

		Convey("restricts to address properly", func() {
			address := "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"
			q := makeQuery("", "asc", 0)
			q.AccountAddress = address
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 2)
			So(records[0].ID, ShouldEqual, 8589946881)
			So(records[1].ID, ShouldEqual, 12884905985)
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.LedgerSequence = 2
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := toid.Parse(r.TransactionID)
				So(toid.LedgerSequence, ShouldEqual, 2)
			}
		})

		Convey("restricts to transaction properly", func() {
			q := makeQuery("", "asc", 0)
			q.TransactionHash = "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d"
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 1)

			for _, r := range records {
				So(r.TransactionID, ShouldEqual, 8589938688)
			}
		})

		Convey("errors if more than one filter is supplied", func() {
			table := []struct {
				Hash    string
				Ledger  int32
				Address string
			}{
				{"1", 1, "1"},
				{"", 1, "1"},
				{"1", 1, ""},
				{"1", 0, "1"},
			}

			for _, o := range table {
				q := makeQuery("", "asc", 0)
				q.TransactionHash = o.Hash
				q.LedgerSequence = o.Ledger
				q.AccountAddress = o.Address

				err := Select(ctx, q, &records)
				So(err, ShouldNotBeNil)
			}

		})

		Convey("obeys the type filter", func() {
			test.LoadScenario("pathed_payment")

			q := makeQuery("", "asc", 0)
			q.TypeFilter = PaymentTypeFilter
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 10)

		})
	})
}
