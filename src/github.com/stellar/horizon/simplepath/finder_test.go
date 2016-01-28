package simplepath

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/test"
)

func TestFinder(t *testing.T) {

	Convey("Finder", t, func() {
		test.LoadScenario("paths")
		conn := test.OpenDatabase(test.StellarCoreDatabaseUrl())
		defer conn.Close()

		finder := &Finder{
			Ctx:      test.Context(),
			SqlQuery: db.SqlQuery{conn},
		}

		native := makeAsset(xdr.AssetTypeAssetTypeNative, "", "")
		usd := makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"USD",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN")
		eur := makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"EUR",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN")

		Convey("Find", func() {
			query := paths.Query{
				DestinationAddress: "GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V",
				DestinationAsset:   eur,
				DestinationAmount:  xdr.Int64(200000000),
				SourceAssets:       []xdr.Asset{usd},
			}

			paths, err := finder.Find(query)
			So(err, ShouldBeNil)
			So(len(paths), ShouldEqual, 3)

			query.DestinationAmount = xdr.Int64(200000001)
			paths, err = finder.Find(query)
			So(err, ShouldBeNil)
			So(len(paths), ShouldEqual, 2)

			query.DestinationAmount = xdr.Int64(500000001)
			paths, err = finder.Find(query)
			So(err, ShouldBeNil)
			So(len(paths), ShouldEqual, 0)
		})

		Convey("regression: paths that involve native currencies can be found", func() {

			query := paths.Query{
				DestinationAddress: "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
				DestinationAsset:   native,
				DestinationAmount:  xdr.Int64(1),
				SourceAssets:       []xdr.Asset{usd, native},
			}

			paths, err := finder.Find(query)
			So(err, ShouldBeNil)
			So(len(paths), ShouldEqual, 2)
		})
	})
}
