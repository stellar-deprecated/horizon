package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestOperationPageQuery(t *testing.T) {
	Convey("OperationPageQuery", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()
		defer db.Close()

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
			records := MustResults(makeQuery("", "asc", 0))
			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, OperationRecord{})
				return r.(OperationRecord).Id
			})

			// desc orders descending by id
			records = MustResults(makeQuery("", "desc", 0))
			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, OperationRecord{})
				return r.(OperationRecord).Id
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			records := MustResults(makeQuery("", "asc", 3))
			So(len(records), ShouldEqual, 3)

			// returns all rows if limit is higher
			records = MustResults(makeQuery("", "asc", 10))
			So(len(records), ShouldEqual, 4)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record := MustFirst(makeQuery("", "asc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884905984)

			// highest id if ordered descending and no cursor
			record = MustFirst(makeQuery("", "desc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 17179873280)

			// starts after the cursor if ordered ascending
			record = MustFirst(makeQuery("12884905984", "asc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884910080)

			// starts before the cursor if ordered descending
			record = MustFirst(makeQuery("17179873280", "desc", 0))
			So(record.(OperationRecord).Id, ShouldEqual, 12884914176)
		})

		Convey("restricts to address properly", func() {
			address := "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ"
			q := makeQuery("", "asc", 0)
			q.AccountAddress = address
			r := MustResults(q)

			So(len(r), ShouldEqual, 2)
			So(r[0].(OperationRecord).Id, ShouldEqual, 12884914176)
			So(r[1].(OperationRecord).Id, ShouldEqual, 17179873280)
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.LedgerSequence = 3
			records := MustResults(q)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := ParseTotalOrderId(r.(OperationRecord).TransactionId)
				So(toid.LedgerSequence, ShouldEqual, 3)
			}
		})

		Convey("restricts to transaction properly", func() {
			q := makeQuery("", "asc", 0)
			q.TransactionHash = "b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369"
			records := MustResults(q)

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

				_, err := Results(q)
				So(err, ShouldNotBeNil)
			}

		})
	})
}
