package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestOrderBookSummaryQuery(t *testing.T) {

	Convey("OrderBookSummaryQuery", t, func() {
		test.LoadScenario("order_books")

		q := OrderBookSummaryQuery{
			SqlQuery:    SqlQuery{core},
			BaseType:    xdr.AssetTypeAssetTypeCreditAlphanum4,
			BaseCode:    "USD",
			BaseIssuer:  "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4",
			CounterType: xdr.AssetTypeAssetTypeNative,
		}

		Convey("works in either direction", func() {
			var result OrderBookSummaryRecord
			var inversion OrderBookSummaryRecord

			So(Get(ctx, q, &result), ShouldBeNil)
			So(Get(ctx, q.Invert(), &inversion), ShouldBeNil)

			So(len(result.Asks), ShouldEqual, 3)
			So(len(result.Bids), ShouldEqual, 3)

			// the asks of one side are the bids on the other
			So(result.Asks[0].OfferID, ShouldEqual, inversion.Bids[2].OfferID)
			So(result.Asks[1].OfferID, ShouldEqual, inversion.Bids[1].OfferID)
			So(result.Asks[2].OfferID, ShouldEqual, inversion.Bids[0].OfferID)
			So(result.Bids[0].OfferID, ShouldEqual, inversion.Asks[2].OfferID)
			So(result.Bids[1].OfferID, ShouldEqual, inversion.Asks[1].OfferID)
			So(result.Bids[2].OfferID, ShouldEqual, inversion.Asks[0].OfferID)
		})

		Convey("Invert()", func() {
			q2 := q.Invert()
			So(q2.BaseType, ShouldEqual, q.CounterType)
			So(q2.BaseCode, ShouldEqual, q.CounterCode)
			So(q2.BaseIssuer, ShouldEqual, q.CounterIssuer)
			So(q2.CounterType, ShouldEqual, q.BaseType)
			So(q2.CounterCode, ShouldEqual, q.BaseCode)
			So(q2.CounterIssuer, ShouldEqual, q.BaseIssuer)
		})
	})
}
