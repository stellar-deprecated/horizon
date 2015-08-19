package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/test"
)

func TestOrderBookActions(t *testing.T) {
	test.LoadScenario("trades")
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

		Convey("(same currency):       GET /order_book?base_type=native&counter_type=native", func() {})
		Convey("(incomplete currency): GET /order_book?base_type=native&counter_type=alphanum_4&counter_code=USD", func() {})
		Convey("(happy path):          GET /order_book?base_type=native&counter_type=alphanum_4&counter_code=USD&counter_issuer=GD37HGFJ5MA6RIROIZWB6CZGMAOEBJ25SJSSBNW2X34ERX3O4BDF54SJ", func() {})

		Convey("Reversing the base/counter assets returns an summary where asks/bids are reversed", func() {

		})

	})
}
