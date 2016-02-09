package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/test"
)

func TestLedgerPageQuery(t *testing.T) {
	test.LoadScenario("base")

	var records []history.Ledger

	Convey("LedgerPageQuery", t, func() {
		pq, err := NewPageQuery("", "asc", 2)
		So(err, ShouldBeNil)

		q := LedgerPageQuery{SqlQuery{historyDb}, pq}
		err = Select(ctx, q, &records)

		So(err, ShouldBeNil)
		So(len(records), ShouldEqual, 2)
		So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
			return r.(history.Ledger).ID
		})

		lastLedger := records[len(records)-1]
		q.Cursor = lastLedger.PagingToken()

		err = Select(ctx, q, &records)

		So(err, ShouldBeNil)
		t.Log(records)
		So(len(records), ShouldEqual, 1)
	})
}
