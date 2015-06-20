package db

import (
	"fmt"
	"math"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestCoreOfferPageByCurrencyQuery(t *testing.T) {
	test.LoadScenario("order_books")

	Convey("CoreOfferPageByCurrencyQuery", t, func() {

		makeQuery := func(c string, o string, l int32) CoreOfferPageByCurrencyQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return CoreOfferPageByCurrencyQuery{
				SqlQuery:  SqlQuery{core},
				PageQuery: pq,
			}
		}

		simpleQuery := makeQuery("", "asc", 0)
		simpleQuery.TakerGetsType = xdr.CurrencyTypeCurrencyTypeAlphanum
		simpleQuery.TakerGetsCode = "USD"
		simpleQuery.TakerGetsIssuer = "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"
		simpleQuery.TakerPaysType = xdr.CurrencyTypeCurrencyTypeNative

		// TakerPaysType   xdr.CurrencyType
		// TakerPaysCode   string
		// TakerPaysIssuer string
		// TakerGetsType   xdr.CurrencyType
		// TakerGetsCode   string
		// TakerGetsIssuer string

		Convey("filters properly", func() {
			// native offers
			q := simpleQuery

			records := MustResults(ctx, q)
			So(len(records), ShouldEqual, 3)

			// all non-native
			q.TakerGetsType = xdr.CurrencyTypeCurrencyTypeAlphanum
			q.TakerGetsCode = "USD"
			q.TakerGetsIssuer = "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"
			q.TakerPaysType = xdr.CurrencyTypeCurrencyTypeAlphanum
			q.TakerPaysCode = "BTC"
			q.TakerPaysIssuer = "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"

			records = MustResults(ctx, q)
			So(len(records), ShouldEqual, 3)

			// non-existent order book
			q.TakerGetsType = xdr.CurrencyTypeCurrencyTypeAlphanum
			q.TakerGetsCode = "USD"
			q.TakerGetsIssuer = "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"
			q.TakerPaysType = xdr.CurrencyTypeCurrencyTypeAlphanum
			q.TakerPaysCode = "EUR"
			q.TakerPaysIssuer = "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"

			records = MustResults(ctx, q)
			So(len(records), ShouldEqual, 0)
		})

		Convey("orders properly", func() {
			// asc orders ascending by price
			q := simpleQuery
			records := MustResults(ctx, q)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Price
			})

			// asc orders ascending by price
			q = simpleQuery
			q.PageQuery.Order = "desc"
			records = MustResults(ctx, q)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Price
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			q := simpleQuery
			q.PageQuery.Limit = 2
			records := MustResults(ctx, q)
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			q = simpleQuery
			q.PageQuery.Limit = 10
			records = MustResults(ctx, q)
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			// lowest price if ordered ascending and no cursor
			q := simpleQuery
			record := MustFirst(ctx, q)
			So(record.(CoreOfferRecord).Price, ShouldEqual, 150000000)

			// highest id if ordered descending and no cursor
			q = simpleQuery
			q.PageQuery.Order = "desc"
			q.PageQuery.Cursor = fmt.Sprintf("%d", math.MaxInt64)
			record = MustFirst(ctx, q)
			So(record.(CoreOfferRecord).Price, ShouldEqual, 500000000)

			// starts after the cursor if ordered ascending
			q = simpleQuery
			q.PageQuery.Cursor = "150000000"
			record = MustFirst(ctx, q)
			So(record.(CoreOfferRecord).Price, ShouldEqual, 200000000)

			// starts before the cursor if ordered descending
			q = simpleQuery
			q.PageQuery.Order = "desc"
			q.PageQuery.Cursor = "500000000"
			record = MustFirst(ctx, q)
			So(record.(CoreOfferRecord).Price, ShouldEqual, 200000000)
		})

	})
}
