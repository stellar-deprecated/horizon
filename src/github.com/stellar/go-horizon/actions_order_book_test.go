package horizon

import (
	"encoding/json"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/test"
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

		Convey("(missing currency): GET /order_book?base_type=native", func() {
			w := rh.Get("/order_book?base_type=native", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(invalid type): GET /order_book?base_type=native&counter_type=nothing", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=nothing", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?base_type=nothing&counter_type=native", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(missing code): GET /order_book?base_type=native&counter_type=alphanum_4&counter_issuer=123", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=alphanum_4&counter_issuer=123", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?counter_type=native&base_type=alphanum_4&base_issuer=123", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(missing issuer): GET /order_book?base_type=native&counter_type=alphanum_4&counter_code=USD", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=alphanum_4&counter_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})

			w = rh.Get("/order_book?counter_type=native&base_type=alphanum_4&base_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(same currency): GET /order_book?base_type=native&counter_type=native", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=native", test.RequestHelperNoop)
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

		Convey("(incomplete currency): GET /order_book?base_type=native&counter_type=alphanum_4&counter_code=USD", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=alphanum_4&counter_code=USD", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 400)
			So(w.Body, ShouldBeProblem, problem.P{Type: "invalid_order_book"})
		})

		Convey("(happy path): GET /order_book?base_type=native&counter_type=alphanum_4&counter_code=USD&counter_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", func() {
			w := rh.Get("/order_book?base_type=native&counter_type=alphanum_4&counter_code=USD&counter_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", test.RequestHelperNoop)
			t.Log(w.Body.String())
			So(w.Code, ShouldEqual, 200)
			var result OrderBookSummaryResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)

			So(result.Base.AssetType, ShouldEqual, "native")
			So(result.Base.AssetCode, ShouldEqual, "")
			So(result.Base.AssetIssuer, ShouldEqual, "")
			So(result.Counter.AssetType, ShouldEqual, "alphanum_4")
			So(result.Counter.AssetCode, ShouldEqual, "USD")
			So(result.Counter.AssetIssuer, ShouldEqual, "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")
			So(len(result.Asks), ShouldEqual, 3)
			So(len(result.Bids), ShouldEqual, 3)

		})
	})
}
