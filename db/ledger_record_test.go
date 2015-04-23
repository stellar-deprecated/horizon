package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestLedgerBySequenceQuery(t *testing.T) {

	Convey("LedgerBySequenceQuery", t, func() {
		db, err := OpenTestDatabase()
		So(err, ShouldBeNil)

		Convey("Existing record behavior", func() {
			sequence := int32(2)
			var q Query = LedgerBySequenceQuery{sequence}
			ledgers, err := q.Run(db)

			So(err, ShouldBeNil)
			So(len(ledgers), ShouldEqual, 1)

			found := ledgers[0].(LedgerRecord)
			So(found.Sequence, ShouldEqual, sequence)
		})

		Convey("Missing record behavior", func() {
			sequence := int32(-1)
			var q Query = LedgerBySequenceQuery{sequence}
			ledgers, err := q.Run(db)

			So(err, ShouldBeNil)
			So(len(ledgers), ShouldEqual, 0)
		})

	})
}
