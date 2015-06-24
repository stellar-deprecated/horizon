package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestTransactionActions(t *testing.T) {

	Convey("Transactions Actions:", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /transactions/da3dae3d6baef2f56d53ff9fa4ddbc6cbda1ac798f0faa7de8edac9597c1dc0c", func() {
			w := rh.Get("/transactions/da3dae3d6baef2f56d53ff9fa4ddbc6cbda1ac798f0faa7de8edac9597c1dc0c", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)

			var result TransactionResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Hash, ShouldEqual, "da3dae3d6baef2f56d53ff9fa4ddbc6cbda1ac798f0faa7de8edac9597c1dc0c")
		})

		Convey("GET /transactions/not_real", func() {
			w := rh.Get("/transactions/not_real", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /transactions", func() {
			w := rh.Get("/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 4)
		})

		Convey("GET /ledgers/:ledger_id/transactions", func() {
			w := rh.Get("/ledgers/2/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/3/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/ledgers/4/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /accounts/:account_od/transactions", func() {
			w := rh.Get("/accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)

			w = rh.Get("/accounts/gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/accounts/gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ/transactions", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

	})
}
