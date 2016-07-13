package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestPaymentActions(t *testing.T) {
	test.LoadScenario("base")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Payment Actions:", t, func() {

		Convey("GET /payments", func() {
			w := rh.Get("/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/payments", func() {
			w := rh.Get("/ledgers/1/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/3/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_id/payments", func() {
			w := rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			test.LoadScenario("pathed_payment")
			w = rh.Get("/accounts/GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

		Convey("GET /transactions/:tx_id/payments", func() {
			test.LoadScenario("pathed_payment")

			w := rh.Get("/transactions/b52f16ffb98c047e33b9c2ec30880330cde71f85b3443dae2c5cb86c7d4d8452/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/transactions/1d2a4be72470658f68db50eef29ea0af3f985ce18b5c218f03461d40c47dc292/payments")
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

	})
}
