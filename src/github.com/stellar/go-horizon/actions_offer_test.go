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

		Convey("GET /accounts/GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W/offers", func() {
			w := rh.Get("/accounts/GAJFK65MU3WQW4PZYJXBS7LXLXHHZB2RNVX7EC6DUZYU2NE4VMANPX2W/offers", test.RequestHelperNoop)

			t.Log(w.Body.String())

			So(w.Code, ShouldEqual, 200)
			So(w.Body, ShouldBePageOf, 3)
		})

	})
}
