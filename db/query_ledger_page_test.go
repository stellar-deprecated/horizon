package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestLedgerPageQuery(t *testing.T) {

	Convey("LedgerPageQuery", t, func() {
		test.LoadScenario("base")
		db := OpenTestDatabase()

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
}
