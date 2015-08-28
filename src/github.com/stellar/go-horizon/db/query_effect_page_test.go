package db

import (
	"fmt"
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
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
			So(record.HistoryOperationID, ShouldEqual, 8589938688)
			So(record.Order, ShouldEqual, 0)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 12884905984)
			So(record.Order, ShouldEqual, 1)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("8589938688-0", "asc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 8589938688)
			So(record.Order, ShouldEqual, 1)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("12884905984-1", "desc", 0), &record)
			So(record.HistoryOperationID, ShouldEqual, 12884905984)
			So(record.Order, ShouldEqual, 0)
		})

		Convey("restricts to address properly", func() {
			address := "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"
			q := makeQuery("", "asc", 0)
			q.AccountAddress = address
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 2)
			So(records[0].HistoryAccountID, ShouldEqual, 8589938688)
			So(records[1].HistoryAccountID, ShouldEqual, 8589938688)
		})

		Convey("restricts to ledger properly", func() {
			q := makeQuery("", "asc", 0)
			q.LedgerSequence = 3
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 2)

			for _, r := range records {
				toid := ParseTotalOrderId(r.HistoryOperationID)
				So(toid.LedgerSequence, ShouldEqual, 3)
			}
		})

		Convey("restricts to transaction properly", func() {
			q := makeQuery("", "asc", 0)
			q.TransactionHash = "99fd775e6eed3e331c7df84b540d955db4ece9f57d22980715918acb7ce5bbf4"
			MustSelect(ctx, q, &records)

			So(len(records), ShouldEqual, 3)

			for _, r := range records {
				toid := ParseTotalOrderId(r.HistoryOperationID)
				So(toid.LedgerSequence, ShouldEqual, 2)
				So(toid.TransactionOrder, ShouldEqual, 1)
			}
		})

		Convey("errors if more than one filter is supplied", func() {
			table := []struct {
				Hash    string
				Ledger  int32
				Address string
				Op      int64
			}{
				// all on
				{"1", 1, "1", 1},
				// three on
				{"", 1, "1", 1},
				{"1", 0, "1", 1},
				{"1", 1, "", 1},
				{"1", 1, "1", 0},
				// two on
				{"1", 1, "", 0},
				{"", 1, "1", 0},
				{"", 0, "1", 1},
				{"1", 0, "1", 0},
				{"", 1, "", 1},
				{"1", 0, "", 1},
			}

			for _, o := range table {
				q := makeQuery("", "asc", 0)
				q.TransactionHash = o.Hash
				q.LedgerSequence = o.Ledger
				q.AccountAddress = o.Address
				q.OperationID = o.Op

				err := Select(ctx, q, &records)
				So(err, ShouldNotBeNil)
			}

		})

	})
}
