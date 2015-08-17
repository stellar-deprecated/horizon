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
			w := rh.Get("/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/operations", test.RequestHelperNoop)
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
			w := rh.Get("/transactions/99fd775e6eed3e331c7df84b540d955db4ece9f57d22980715918acb7ce5bbf4/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/transactions/7c51321eac0223879d74a63ea63ec0fb5aa8091f4a775f47263ebf6add8c3db5/operations", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /operations/:id", func() {
			w := rh.Get("/operations/8589938688", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)

			var result OperationResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result["paging_token"], ShouldEqual, "8589938688")

			w = rh.Get("/operations/10", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 404)
		})

	})
}
