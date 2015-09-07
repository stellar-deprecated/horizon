package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestOrderBookSummaryQuery(t *testing.T) {

	Convey("OrderBookSummaryQuery", t, func() {
		test.LoadScenario("order_books")

		q := OrderBookSummaryQuery{
			SqlQuery:      SqlQuery{core},
			SellingType:   xdr.AssetTypeAssetTypeCreditAlphanum4,
			SellingCode:   "USD",
			SellingIssuer: "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4",
			BuyingType:    xdr.AssetTypeAssetTypeNative,
		}

		Convey("loads correctly", func() {
			var result OrderBookSummaryRecord
			So(Select(ctx, q, &result), ShouldBeNil)

			asks := result.Asks()
			bids := result.Bids()

			So(asks[0].Amount, ShouldEqual, 10)
			So(asks[0].Pricen, ShouldEqual, 15)
			So(asks[0].Priced, ShouldEqual, 1)

			So(asks[1].Amount, ShouldEqual, 100)
			So(asks[1].Pricen, ShouldEqual, 20)
			So(asks[1].Priced, ShouldEqual, 1)

			So(asks[2].Amount, ShouldEqual, 1000)
			So(asks[2].Pricen, ShouldEqual, 50)
			So(asks[2].Priced, ShouldEqual, 1)

			So(bids[0].Amount, ShouldEqual, 1)
			So(bids[0].Pricen, ShouldEqual, 10)
			So(bids[0].Priced, ShouldEqual, 1)

			So(bids[1].Amount, ShouldEqual, 11)
			So(bids[1].Pricen, ShouldEqual, 9)
			So(bids[1].Priced, ShouldEqual, 1)

			So(bids[2].Amount, ShouldEqual, 200)
			So(bids[2].Pricen, ShouldEqual, 5)
			So(bids[2].Priced, ShouldEqual, 1)
		})

		Convey("works in either direction", func() {
			var result OrderBookSummaryRecord
			var inversion OrderBookSummaryRecord

			So(Select(ctx, q, &result), ShouldBeNil)
			So(Select(ctx, q.Invert(), &inversion), ShouldBeNil)

			asks := result.Asks()
			bids := result.Bids()

			iasks := inversion.Asks()
			ibids := inversion.Bids()

			So(len(result), ShouldEqual, 6)
			So(len(inversion), ShouldEqual, 6)

			// the asks of one side are the bids on the other
			So(asks[0].Pricef, ShouldEqual, ibids[0].InvertPricef())
			So(asks[1].Pricef, ShouldEqual, ibids[1].InvertPricef())
			So(asks[2].Pricef, ShouldEqual, ibids[2].InvertPricef())
			So(bids[0].Pricef, ShouldEqual, iasks[0].InvertPricef())
			So(bids[1].Pricef, ShouldEqual, iasks[1].InvertPricef())
			So(bids[2].Pricef, ShouldEqual, iasks[2].InvertPricef())
		})

		Convey("Invert()", func() {
			q2 := q.Invert()
			So(q2.SellingType, ShouldEqual, q.BuyingType)
			So(q2.SellingCode, ShouldEqual, q.BuyingCode)
			So(q2.SellingIssuer, ShouldEqual, q.BuyingIssuer)
			So(q2.BuyingType, ShouldEqual, q.SellingType)
			So(q2.BuyingCode, ShouldEqual, q.SellingCode)
			So(q2.BuyingIssuer, ShouldEqual, q.SellingIssuer)
		})
	})
}
