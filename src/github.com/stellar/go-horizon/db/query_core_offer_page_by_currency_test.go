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
		var records []CoreOfferRecord

		makeQuery := func(c string, o string, l int32) CoreOfferPageByCurrencyQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return CoreOfferPageByCurrencyQuery{
				SqlQuery:  SqlQuery{core},
				PageQuery: pq,
			}
		}

		simpleQuery := makeQuery("", "asc", 0)
		simpleQuery.SellingAssetType = xdr.AssetTypeAssetTypeCreditAlphanum4
		simpleQuery.SellingAssetCode = "USD"
		simpleQuery.SellingIssuer = "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"
		simpleQuery.BuyingAssetType = xdr.AssetTypeAssetTypeNative

		Convey("filters properly", func() {
			// native offers
			q := simpleQuery

			MustSelect(ctx, q, &records)
			So(len(records), ShouldEqual, 3)

			// all non-native
			q.SellingAssetType = xdr.AssetTypeAssetTypeCreditAlphanum4
			q.SellingAssetCode = "USD"
			q.SellingIssuer = "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"
			q.BuyingAssetType = xdr.AssetTypeAssetTypeCreditAlphanum4
			q.BuyingAssetCode = "BTC"
			q.BuyingIssuer = "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"

			MustSelect(ctx, q, &records)
			So(len(records), ShouldEqual, 3)

			// non-existent order book
			q.SellingAssetType = xdr.AssetTypeAssetTypeCreditAlphanum4
			q.SellingAssetCode = "USD"
			q.SellingIssuer = "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"
			q.BuyingAssetType = xdr.AssetTypeAssetTypeCreditAlphanum4
			q.BuyingAssetCode = "EUR"
			q.BuyingIssuer = "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"

			MustSelect(ctx, q, &records)
			So(len(records), ShouldEqual, 0)
		})

		Convey("orders properly", func() {
			// asc orders ascending by price
			q := simpleQuery
			MustSelect(ctx, q, &records)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Price
			})

			// asc orders ascending by price
			q = simpleQuery
			q.PageQuery.Order = "desc"
			MustSelect(ctx, q, &records)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Price
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			q := simpleQuery
			q.PageQuery.Limit = 2
			MustSelect(ctx, q, &records)
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			q = simpleQuery
			q.PageQuery.Limit = 10
			MustSelect(ctx, q, &records)
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			var record CoreOfferRecord
			// lowest price if ordered ascending and no cursor
			q := simpleQuery
			MustGet(ctx, q, &record)
			So(record.Price, ShouldEqual, 150000000)

			// highest id if ordered descending and no cursor
			q = simpleQuery
			q.PageQuery.Order = "desc"
			q.PageQuery.Cursor = fmt.Sprintf("%d", math.MaxInt64)
			MustGet(ctx, q, &record)
			So(record.Price, ShouldEqual, 500000000)

			// starts after the cursor if ordered ascending
			q = simpleQuery
			q.PageQuery.Cursor = "150000000"
			MustGet(ctx, q, &record)
			So(record.Price, ShouldEqual, 200000000)

			// starts before the cursor if ordered descending
			q = simpleQuery
			q.PageQuery.Order = "desc"
			q.PageQuery.Cursor = "500000000"
			MustGet(ctx, q, &record)
			So(record.Price, ShouldEqual, 200000000)
		})

	})
}
