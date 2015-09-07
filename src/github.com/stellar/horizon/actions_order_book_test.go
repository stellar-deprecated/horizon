package horizon

import (
	"encoding/json"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/test"
)

func TestOrderBookActions(t *testing.T) {
	test.LoadScenario("order_books")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Order Book Actions:", t, func() {
		Convey("(no query args): GET /order_book", func() {
			w := rh.Get("/order_book", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(missing currency): GET /order_book?selling_asset_type=native", func() {
			w := rh.Get("/order_book?selling_asset_type=native", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(invalid type): GET /order_book?selling_asset_type=native&buying_asset_type=nothing", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=nothing", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?selling_asset_type=nothing&buying_asset_type=native", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(missing code): GET /order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_issuer=123", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_issuer=123", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?buying_asset_type=native&selling_asset_type=credit_alphanum4&selling_issuer=123", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(missing issuer): GET /order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?buying_asset_type=native&selling_asset_type=credit_alphanum4&selling_asset_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(same currency): GET /order_book?selling_asset_type=native&buying_asset_type=native", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=native", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			var result map[string]interface{}
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)

			// ensure bids and asks are empty
			prices := result["asks"].([]interface{})
			So(len(prices), ShouldEqual, 0)
			prices = result["bids"].([]interface{})
			So(len(prices), ShouldEqual, 0)

		})

		Convey("(incomplete currency): GET /order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(happy path): GET /order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD&buying_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", func() {
			w := rh.Get("/order_book?selling_asset_type=native&buying_asset_type=credit_alphanum4&buying_asset_code=USD&buying_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", test.RequestHelperNoop)
			t.Log(w.Body.String())
			So(w.Code, ShouldEqual, 200)
			var result OrderBookSummaryResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)

			So(result.Selling.AssetType, ShouldEqual, "native")
			So(result.Selling.AssetCode, ShouldEqual, "")
			So(result.Selling.AssetIssuer, ShouldEqual, "")
			So(result.Buying.AssetType, ShouldEqual, "credit_alphanum4")
			So(result.Buying.AssetCode, ShouldEqual, "USD")
			So(result.Buying.AssetIssuer, ShouldEqual, "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")
			So(len(result.Asks), ShouldEqual, 3)
			So(len(result.Bids), ShouldEqual, 3)

		})
	})
}
