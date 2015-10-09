package actions

import (
	"fmt"
	"math"
	"net/http"
	"net/url"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/test"
	"github.com/zenazn/goji/web"
)

func TestHelpers(t *testing.T) {
	Convey("Action Helpers", t, func() {
		r, _ := http.NewRequest("GET", "/?limit=2&cursor=hello", nil)

		action := &Base{
			Ctx: test.Context(),
			GojiCtx: web.C{
				URLParams: map[string]string{
					"blank":             "",
					"zero":              "0",
					"two":               "2",
					"32min":             fmt.Sprint(math.MinInt32),
					"32max":             fmt.Sprint(math.MaxInt32),
					"64min":             fmt.Sprint(math.MinInt64),
					"64max":             fmt.Sprint(math.MaxInt64),
					"native_asset_type": "native",
					"4_asset_type":      "credit_alphanum4",
					"4_asset_code":      "USD",
					"4_asset_issuer":    "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
					"12_asset_type":     "credit_alphanum12",
					"12_asset_code":     "USD",
					"12_asset_issuer":   "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
				},
				Env: map[interface{}]interface{}{},
			},
			R: r,
		}

		Convey("GetInt32", func() {
			result := action.GetInt32("blank")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt32("zero")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt32("two")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt32("32max")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt32)

			result = action.GetInt32("32min")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MinInt32)

			result = action.GetInt32("limit")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt32("64max")
			So(action.Err, ShouldHaveSameTypeAs, &problem.P{})
			p := action.Err.(*problem.P)
			So(p.Type, ShouldEqual, "bad_request")
			So(p.Extras["invalid_field"], ShouldEqual, "64max")
			action.Err = nil

			result = action.GetInt32("64min")
			So(action.Err, ShouldHaveSameTypeAs, &problem.P{})
			p = action.Err.(*problem.P)
			So(p.Type, ShouldEqual, "bad_request")
			So(p.Extras["invalid_field"], ShouldEqual, "64min")
			action.Err = nil

		})

		Convey("GetInt64", func() {
			result := action.GetInt64("blank")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt64("zero")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 0)

			result = action.GetInt64("two")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, 2)

			result = action.GetInt64("64max")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MaxInt64)

			result = action.GetInt64("64min")
			So(action.Err, ShouldBeNil)
			So(result, ShouldEqual, math.MinInt64)
		})

		Convey("GetPagingParams", func() {
			cursor, order, limit := action.GetPagingParams()
			So(cursor, ShouldEqual, "hello")
			So(limit, ShouldEqual, 2)
			So(order, ShouldEqual, "")
		})

		Convey("GetAccountID", func() {
			_ = action.GetAccountID("4_asset_issuer")
			So(action.Err, ShouldBeNil)
		})

		Convey("GetAsset", func() {
			ts := action.GetAsset("native_")
			So(action.Err, ShouldBeNil)
			So(ts.Type, ShouldEqual, xdr.AssetTypeAssetTypeNative)

			ts = action.GetAsset("4_")
			So(action.Err, ShouldBeNil)
			So(ts.Type, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum4)

			ts = action.GetAsset("12_")
			So(action.Err, ShouldBeNil)
			So(ts.Type, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum12)

			So(action.Err, ShouldBeNil)
			action.GetAsset("cursor")
			So(action.Err, ShouldNotBeNil)
		})

		Convey("GetAssetType", func() {
			t := action.GetAssetType("native_asset_type")
			So(t, ShouldEqual, xdr.AssetTypeAssetTypeNative)

			t = action.GetAssetType("4_asset_type")
			So(t, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum4)

			t = action.GetAssetType("12_asset_type")
			So(t, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum12)

			So(action.Err, ShouldBeNil)
			action.GetAssetType("cursor")
			So(action.Err, ShouldNotBeNil)
		})

		Convey("Last-Event-ID overrides cursor", func() {
			action.R.Header.Set("Last-Event-ID", "from_header")
			cursor, _, _ := action.GetPagingParams()
			So(cursor, ShouldEqual, "from_header")
		})

		Convey("Form values override query values", func() {
			So(action.GetString("cursor"), ShouldEqual, "hello")

			action.R.Form = url.Values{
				"cursor": {"goodbye"},
			}
			So(action.GetString("cursor"), ShouldEqual, "goodbye")
		})

		Convey("regression: GetPagQuery does not overwrite err", func() {
			r, _ := http.NewRequest("GET", "/?limit=foo", nil)
			action.R = r
			_, _, _ = action.GetPagingParams()

			So(action.Err, ShouldNotBeNil)
			_ = action.GetPageQuery()
			So(action.Err, ShouldNotBeNil)
		})

		Convey("Path() return the action's http path", func() {
			r, _ := http.NewRequest("GET", "/foo-bar/blah?limit=foo", nil)
			action.R = r
			So(action.Path(), ShouldEqual, "/foo-bar/blah")
		})
	})
}
