package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestLedgerBySequenceQuery(t *testing.T) {

	Convey("LedgerBySequenceQuery", t, func() {
		test.LoadScenario("base")
		var record LedgerRecord

		Convey("Existing record behavior", func() {
			sequence := int32(2)
			q := LedgerBySequenceQuery{
				SqlQuery{historyDb},
				sequence,
			}
			err := Get(ctx, q, &record)
			So(err, ShouldBeNil)
			So(record.Sequence, ShouldEqual, sequence)
		})

		Convey("Missing record behavior", func() {
			sequence := int32(-1)
			query := LedgerBySequenceQuery{
				SqlQuery{historyDb},
				sequence,
			}
			err := Get(ctx, query, &record)
			So(err, ShouldEqual, ErrNoResults)
		})
	})
}
