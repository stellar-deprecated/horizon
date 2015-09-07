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
			w := rh.Get("/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/payments", func() {
			w := rh.Get("/ledgers/1/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/3/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_id/payments", func() {
			w := rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			test.LoadScenario("pathed_payment")
			w = rh.Get("/accounts/GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

		Convey("GET /transactions/:tx_id/payments", func() {
			test.LoadScenario("pathed_payment")

			w := rh.Get("/transactions/42450ffe3956b8618cffaae48665c252869440aeb41fd8bf4921929a61982630/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/transactions/95324dec7c94f8cc992522794b2a84a732cddcb5641992589cfe328884a4c132/payments", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

	})
}
