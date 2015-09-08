package horizon

import (
	"encoding/json"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestOperationActions(t *testing.T) {
	test.LoadScenario("base")

	Convey("Operation Actions:", t, func() {
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /operations", func() {
			w := rh.Get("/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/operations", func() {
			w := rh.Get("/ledgers/1/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/2/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/ledgers/3/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_id/operations", func() {
			w := rh.Get("/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/accounts/GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

		Convey("GET /transactions/:tx_id/operations", func() {
			w := rh.Get("/transactions/c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/transactions/f70627f6d076a346902bdeaa0d55d8403dfcbdfad1c79d58baf54031a5c477ce/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /operations/:id", func() {
			w := rh.Get("/operations/8589938689", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)

			var result OperationResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result["paging_token"], ShouldEqual, "8589938689")

			w = rh.Get("/operations/10", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /ledgers/100/operations", func() {
			w := rh.Get("/ledgers/100/operations", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 404)
		})

	})
}
