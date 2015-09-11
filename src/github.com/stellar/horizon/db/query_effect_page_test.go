package db

import (
	"fmt"
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestEffectPageQuery(t *testing.T) {
	test.LoadScenario("base")

	Convey("EffectPageQuery", t, func() {
		var records []EffectRecord

		makeQuery := func(c string, o string, l int32) EffectPageQuery {
			pq := MustPageQuery(c, o, l)

			return EffectPageQuery{
				SqlQuery:  SqlQuery{history},
				PageQuery: pq,
			}
		}

		Convey("orders properly", func() {
			// asc orders ascending by operation_id, order
			MustSelect(ctx, makeQuery("", "asc", 0), &records)
			var cmp OrderComparator = func(idx int, l, r interface{}) string {
				leff := l.(EffectRecord)
				reff := r.(EffectRecord)

				if leff.ID() > reff.ID() {
					return fmt.Sprintf("effects are not in order: %s %s", leff.ID(), reff.ID())
				}

				return ""
			}

			So(records, ShouldBeOrdered, cmp)

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0), &records)
			cmp = func(idx int, l, r interface{}) string {
				leff := l.(EffectRecord)
				reff := r.(EffectRecord)

				if leff.ID() < reff.ID() {
					return fmt.Sprintf("effects are not in order: %s %s", leff.ID(), reff.ID())
				}

				return ""
			}

			So(records, ShouldBeOrdered, cmp)
		})

		Convey("limits properly", func() {
			// returns number specified
			MustSelect(ctx, makeQuery("", "asc", 3), &records)
			So(len(records), ShouldEqual, 3)

			// returns all rows if limit is higher
			MustSelect(ctx, makeQuery("", "asc", 20), &records)
			So(len(records), ShouldEqual, 11)
		})

		Convey("cursor works properly", func() {
			var record EffectRecord

			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 8589938689)
			So(record.Order, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 12884905985)
			So(record.Order, ShouldEqual, 2)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("8589938689-1", "asc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 8589938689)
			So(record.Order, ShouldEqual, 2)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("12884905985-2", "desc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 12884905985)
			So(record.Order, ShouldEqual, 1)
		})

		Convey("restricts to address properly", func() {
			address := "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"
			q := makeQuery("", "asc", 0)
			q.Filter = &EffectAccountFilter{q.SqlQuery, address}
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)
			So(records[0].HistoryAccountID, ShouldEqual, 8589938689)
			So(records[1].HistoryAccountID, ShouldEqual, 8589938689)
			So(records[2].HistoryAccountID, ShouldEqual, 8589938689)
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.Filter = &EffectLedgerFilter{3}
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 2)

			for _, r := range records {
				toid := ParseTotalOrderId(r.HistoryOperationID)
				So(toid.LedgerSequence, ShouldEqual, 3)
			}
		})

		Convey("restricts to operation properly", func() {
			q := makeQuery("", "asc", 0)
			q.Filter = &EffectOperationFilter{8589938689}
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := ParseTotalOrderId(r.HistoryOperationID)
				So(toid.LedgerSequence, ShouldEqual, 2)
				So(toid.TransactionOrder, ShouldEqual, 1)
				So(toid.OperationOrder, ShouldEqual, 1)
			}
		})

		Convey("restricts to transaction properly", func() {
			q := makeQuery("", "asc", 0)
			hash := "c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74"
			q.Filter = &EffectTransactionFilter{q.SqlQuery, hash}
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := ParseTotalOrderId(r.HistoryOperationID)
				So(toid.LedgerSequence, ShouldEqual, 2)
				So(toid.TransactionOrder, ShouldEqual, 1)
			}
		})

	})
}
