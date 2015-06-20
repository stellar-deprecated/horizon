package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestPaymentActions(t *testing.T) {
	test.LoadScenario("base")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Payment Actions:", t, func() {

		Convey("GET /payments", func() {
			w := rh.Get("/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/payments", func() {
			w := rh.Get("/ledgers/2/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/4/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_id/payments", func() {
			w := rh.Get("/accounts/gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			test.LoadScenario("pathed_payment")
			w = rh.Get("/accounts/gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

		Convey("GET /transactions/:tx_id/payments", func() {
			test.LoadScenario("pathed_payment")

			w := rh.Get("/transactions/dffaa6b14246bb4cc3ab8ac414aec9cb93e86003cb22ff1297b3fe4623974d98/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/transactions/ab38509dc9e16c08b084d7f7279fd45f5f4d348ab3b2ed9877c697beaa7e4108/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

	})
}
