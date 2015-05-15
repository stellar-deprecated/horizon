package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestAccountActions(t *testing.T) {

	Convey("Account Actions:", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		Convey("GET /accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", func() {
			w := rh.Get("/accounts/gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 200)

			var result AccountResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Sequence, ShouldEqual, 3)
		})

		Convey("GET /accounts/100", func() {
			w := rh.Get("/accounts/100", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 404)
		})
	})
}
