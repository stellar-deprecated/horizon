package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"strconv"
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
		current := q.Cursor

		for _, ledger := range ledgers {
			ledger := ledger.(LedgerRecord)
			So(ledger.Id, ShouldBeGreaterThan, current)
			current = ledger.Id
		}

		lastLedger := ledgers[len(ledgers)-1].(Pageable)
		cursor, _ := strconv.ParseInt(lastLedger.PagingToken(), 10, 64)
		q.Cursor = cursor

		ledgers, err = Results(q)

		So(err, ShouldBeNil)
		So(len(ledgers), ShouldEqual, 1)

		current = q.Cursor

		for _, ledger := range ledgers {
			ledger := ledger.(LedgerRecord)
			So(ledger.Id, ShouldBeGreaterThan, current)
			current = ledger.Id
		}

	})
}
