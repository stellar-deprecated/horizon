package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestLedgerRecordQueries(t *testing.T) {

	Convey("LedgeRecord Queries", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()

		Convey("LedgerBySequenceQuery", func() {
			Convey("Existing record behavior", func() {
				sequence := int32(2)
				q := LedgerBySequenceQuery{
					GormQuery{&db},
					sequence,
				}
				ledgers, err := Results(q)

				So(err, ShouldBeNil)
				So(len(ledgers), ShouldEqual, 1)

				found := ledgers[0].(LedgerRecord)
				So(found.Sequence, ShouldEqual, sequence)
			})

			Convey("Missing record behavior", func() {
				sequence := int32(-1)
				var q Query = LedgerBySequenceQuery{
					GormQuery{&db},
					sequence,
				}
				ledgers, err := Results(q)

				So(err, ShouldBeNil)
				So(len(ledgers), ShouldEqual, 0)
			})
		})

		Convey("LedgerPageQuery", func() {
			q := LedgerPageQuery{GormQuery{&db}, 0, "asc", 3}
			ledgers, err := Results(q)

			So(err, ShouldBeNil)
			So(len(ledgers), ShouldEqual, 3)

			// ensure each record is after the previous
			current := q.After

			for _, ledger := range ledgers {
				ledger := ledger.(LedgerRecord)
				So(ledger.Order, ShouldBeGreaterThan, current)
				current = ledger.Order
			}

			lastLedger := ledgers[len(ledgers)-1].(Pageable)
			q.After = lastLedger.PagingToken().(int64)

			ledgers, err = Results(q)

			So(err, ShouldBeNil)
			So(len(ledgers), ShouldEqual, 1)

			current = q.After

			for _, ledger := range ledgers {
				ledger := ledger.(LedgerRecord)
				So(ledger.Order, ShouldBeGreaterThan, current)
				current = ledger.Order
			}
		})

	})
}
