package horizon

import (
	"encoding/json"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestLedgerActions(t *testing.T) {
	test.LoadScenario("base")
	app := NewTestApp()
	defer app.Close()
	rh := NewRequestHelper(app)

	Convey("Ledger Actions:", t, func() {

		Convey("GET /ledgers/1", func() {
			w := rh.Get("/ledgers/1", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 200)

			var result LedgerResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Sequence, ShouldEqual, 1)
		})

		Convey("GET /ledgers/100", func() {
			w := rh.Get("/ledgers/100", test.RequestHelperNoop)

			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /ledgers", func() {

			Convey("With Default Params", func() {
				w := rh.Get("/ledgers", test.RequestHelperNoop)

				var result map[string]interface{}
				err := json.Unmarshal(w.Body.Bytes(), &result)
				So(err, ShouldBeNil)
				So(w.Code, ShouldEqual, 200)

				embedded := result["_embedded"].(map[string]interface{})
				records := embedded["records"].([]interface{})

				So(len(records), ShouldEqual, 3)

			})

			Convey("With A Limit", func() {
				w := rh.Get("/ledgers?limit=1", test.RequestHelperNoop)

				var result map[string]interface{}
				err := json.Unmarshal(w.Body.Bytes(), &result)
				So(err, ShouldBeNil)
				So(w.Code, ShouldEqual, 200)

				embedded := result["_embedded"].(map[string]interface{})
				records := embedded["records"].([]interface{})

				So(len(records), ShouldEqual, 1)

			})

		})
	})
}
