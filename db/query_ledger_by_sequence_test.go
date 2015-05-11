package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestLedgerBySequenceQuery(t *testing.T) {

	Convey("LedgerBySequenceQuery", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()
		defer db.Close()

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
}
