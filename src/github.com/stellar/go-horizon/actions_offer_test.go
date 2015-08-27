package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestOfferActions(t *testing.T) {
	test.LoadScenario("trades")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Offer Actions:", t, func() {

		Convey("GET /accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/offers", func() {
			w := rh.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/offers", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

	})
}
