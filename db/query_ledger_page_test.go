package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestLedgerPageQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("LedgerPageQuery", t, func() {
		pq, err := NewPageQuery("", "asc", 3)
		So(err, ShouldBeNil)

		q := LedgerPageQuery{SqlQuery{history}, pq}

		ledgers := MustResults(ctx, q)
		So(len(ledgers), ShouldEqual, 3)
		So(ledgers, ShouldBeOrderedAscending, func(r interface{}) int64 {
			So(r, ShouldHaveSameTypeAs, LedgerRecord{})
			return int64(r.(LedgerRecord).Sequence)
		})

		q.PageQuery.Order = "desc"
		ledgers = MustResults(ctx, q)
		So(len(ledgers), ShouldEqual, 3)
		So(ledgers, ShouldBeOrderedDescending, func(r interface{}) int64 {
			So(r, ShouldHaveSameTypeAs, LedgerRecord{})
			return int64(r.(LedgerRecord).Sequence)
		})

	})
}
