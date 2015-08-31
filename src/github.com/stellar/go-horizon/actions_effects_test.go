package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestEffectActions(t *testing.T) {
	test.LoadScenario("base")

	Convey("Effect Actions:", t, func() {
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /effects", func() {
			w := rh.Get("/effects?limit=20", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 11)
		})

		Convey("GET /ledgers/:ledger_id/effects", func() {
			w := rh.Get("/ledgers/1/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 0)

			w = rh.Get("/ledgers/2/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 9)

			w = rh.Get("/ledgers/3/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

		Convey("GET /accounts/:account_id/effects", func() {
			w := rh.Get("/accounts/GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 6)

			w = rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)

			w = rh.Get("/accounts/GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 2)
		})

		Convey("GET /transactions/:tx_id/effects", func() {
			w := rh.Get("/transactions/99fd775e6eed3e331c7df84b540d955db4ece9f57d22980715918acb7ce5bbf4/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

		Convey("GET /operations/:op_id/effects", func() {
			w := rh.Get("/operations/8589938688/effects", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})
	})
}
