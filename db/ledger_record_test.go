package db

import (
	"../test"
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestLedgerRecordQueries(t *testing.T) {

	Convey("LedgeRecord Queries", t, func() {
		test.LoadScenario("base")
		db, err := OpenTestDatabase()
		db.LogMode(true)
		So(err, ShouldBeNil)

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

			for i, ledger := range ledgers {
				ledger := ledger.(LedgerRecord)
				So(ledger.Sequence, ShouldEqual, i+1)
			}

			lastLedger := ledgers[len(ledgers)-1].(Pageable)
			q.After = lastLedger.PagingToken().(int32)

			ledgers, err = Results(q)

			So(err, ShouldBeNil)
			So(len(ledgers), ShouldEqual, 1)

			for i, ledger := range ledgers {
				ledger := ledger.(LedgerRecord)
				So(ledger.Sequence, ShouldEqual, i+int(q.After)+1)
			}
		})

	})
}
