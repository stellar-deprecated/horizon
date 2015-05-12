package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestOperationActions(t *testing.T) {
	test.LoadScenario("base")
	app := NewTestApp()
	defer app.Cancel()
	rh := NewRequestHelper(app)

	Convey("Operation Actions:", t, func() {

		Convey("GET /operations", func() {
			w := rh.Get("/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/operations", func() {
			w := rh.Get("/ledgers/2/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/3/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/ledgers/4/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_id/operations", func() {
			w := rh.Get("/accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/accounts/gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/accounts/gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

		Convey("GET /transactions/:tx_id/operations", func() {
			w := rh.Get("/transactions/b313ee4b54d033eafd6bdc9c998b6ee8dbfe814da491b9182de8b63508e31369/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/transactions/83a428d46410a6699dee11c6785cb48ff62c5e403c2bf90efa2dbe862a9b33ab/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

	})
}
