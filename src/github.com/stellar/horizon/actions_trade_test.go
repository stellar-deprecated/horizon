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

	})
}
