package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestOperationPageQuery(t *testing.T) {
	test.LoadScenario("base")
	ctx := test.Context()
	db := OpenTestDatabase()
	defer db.Close()

	Convey("OperationPageQuery", t, func() {
		makeQuery := func(c string, o string, l int32) OperationPageQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return OperationPageQuery{
				SqlQuery:  SqlQuery{db},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by id
			records := MustResults(ctx, makeQuery("", "asc", 0))
			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, OperationRecord{})
				return r.(OperationRecord).Id
			})

			// desc orders descending by id
			records = MustResults(ctx, makeQuery("", "desc", 0))
			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, OperationRecord{})
				return r.(OperationRecord).Id
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			records := MustResults(ctx, makeQuery("", "asc", 3))
			So(len(records), ShouldEqual, 3)

			// returns all rows if limit is higher
			records = MustResults(ctx, makeQuery("", "asc", 10))
			So(len(records), ShouldEqual, 4)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record := MustFirst(ctx, makeQuery("", "asc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884905984)

			// highest id if ordered descending and no cursor
			record = MustFirst(ctx, makeQuery("", "desc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 17179873280)

			// starts after the cursor if ordered ascending
			record = MustFirst(ctx, makeQuery("12884905984", "asc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884910080)

			// starts before the cursor if ordered descending
			record = MustFirst(ctx, makeQuery("17179873280", "desc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884914176)
		})

		Convey("restricts to address properly", func() {
			address := "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ"
			q := makeQuery("", "asc", 0)
			q.AccountAddress = address
			r := MustResults(ctx, q)

			So(len(r), ShouldEqual, 2)
			So(r[0].(OperationRecord).Id, ShouldEqual, 12884914176)
			So(r[1].(OperationRecord).Id, ShouldEqual, 17179873280)
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.LedgerSequence = 3
			records := MustResults(ctx, q)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := ParseTotalOrderId(r.(OperationRecord).TransactionId)
				So(toid.LedgerSequence, ShouldEqual, 3)
			}
		})

		Convey("restricts to transaction properly", func() {
			q := makeQuery("", "asc", 0)
			q.TransactionHash = "da3dae3d6baef2f56d53ff9fa4ddbc6cbda1ac798f0faa7de8edac9597c1dc0c"
			records := MustResults(ctx, q)

			So(len(records), ShouldEqual, 1)

			for _, r := range records {
				So(r.(OperationRecord).TransactionId, ShouldEqual, 12884905984)
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

				_, err := Results(ctx, q)
				So(err, ShouldNotBeNil)
			}

		})

		Convey("obeys the type filter", func() {
			test.LoadScenario("pathed_payment")

			q := makeQuery("", "asc", 0)
			q.TypeFilter = PaymentTypeFilter
			records := MustResults(ctx, q)

			So(len(records), ShouldEqual, 10)

		})
	})
}
