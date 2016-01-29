package simplepath

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/test"
)

func TestOrderBook(t *testing.T) {

	Convey("orderBook", t, func() {
		ob := orderBook{
			Selling: makeAsset(
				xdr.AssetTypeAssetTypeCreditAlphanum4,
				"EUR",
				"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
			Buying: makeAsset(
				xdr.AssetTypeAssetTypeCreditAlphanum4,
				"USD",
				"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
		}

		Convey("Cost from paths scenario", func() {
			test.LoadScenario("paths")
			conn := test.OpenDatabase(test.StellarCoreDatabaseUrl())
			defer conn.Close()
			ob.DB = db.SqlQuery{conn}

			r, err := ob.Cost(ob.Buying, 10000000)
			So(err, ShouldBeNil)
			So(r, ShouldEqual, xdr.Int64(10000000))

			// this cost should consume the entire lowest priced order, whose price
			// is 1.0, thus the output should be the same
			r, err = ob.Cost(ob.Buying, 100000000)
			So(err, ShouldBeNil)
			So(r, ShouldEqual, xdr.Int64(100000000))

			// now we are taking from the next offer, where the price is 2.0
			r, err = ob.Cost(ob.Buying, 100000001)
			So(err, ShouldBeNil)
			So(r, ShouldEqual, xdr.Int64(100000002))

			r, err = ob.Cost(ob.Buying, 500000000)
			So(err, ShouldBeNil)
			So(r, ShouldEqual, xdr.Int64(900000000))

			r, err = ob.Cost(ob.Buying, 500000001)
			So(err, ShouldNotBeNil)
		})

		Convey("Cost from bad_cost scenario", func() {
			test.LoadScenario("bad_cost")
			conn := test.OpenDatabase(test.StellarCoreDatabaseUrl())
			defer conn.Close()
			ob.DB = db.SqlQuery{conn}

			r, err := ob.Cost(ob.Buying, 10000000)
			So(err, ShouldBeNil)
			So(r, ShouldEqual, xdr.Int64(2000000000))
		})
	})
}
