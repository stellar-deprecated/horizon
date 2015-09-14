package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTradeActions(t *testing.T) {

	Convey("Trade Actions:", t, func() {
		test.LoadScenario("trades")
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /accounts/:account_id/trades", func() {
			w := rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/trades", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})

		Convey("GET /order_book/trades", func() {
			url := "/order_book/trades?" +
				"selling_asset_type=credit_alphanum4&" +
				"selling_asset_code=EUR&" +
				"selling_asset_issuer=GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG&" +
				"buying_asset_type=credit_alphanum4&" +
				"buying_asset_code=USD&" +
				"buying_asset_issuer=GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"

			w := rh.Get(url, test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 1)
		})
	})
}
