package horizon

import (
	"encoding/json"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLedgerActions(t *testing.T) {

	Convey("Ledger Actions:", t, func() {
		Convey("GET /ledgers/1", func() {
			test.LoadScenario("base")
			app := NewTestApp()

			r, _ := http.NewRequest("GET", "/ledgers/1", nil)
			w := httptest.NewRecorder()
			c := web.C{
				Env: map[interface{}]interface{}{},
			}

			app.web.router.ServeHTTPC(c, w, r)
			So(w.Code, ShouldEqual, 200)

			var result ledgerResource
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(result.Sequence, ShouldEqual, 1)
		})

		Convey("GET /ledgers/100", func() {
			test.LoadScenario("base")
			app := NewTestApp()

			r, _ := http.NewRequest("GET", "/ledgers/100", nil)
			w := httptest.NewRecorder()
			c := web.C{
				Env: map[interface{}]interface{}{},
			}

			app.web.router.ServeHTTPC(c, w, r)

			So(w.Code, ShouldEqual, 404)
		})

		Convey("GET /ledgers", func() {
			test.LoadScenario("base")
			app := NewTestApp()
			rh := NewRequestHelper(app)

			w := rh.Get("/ledgers", test.RequestHelperNoop)

			var result map[string]interface{}
			err := json.Unmarshal(w.Body.Bytes(), &result)
			So(err, ShouldBeNil)
			So(w.Code, ShouldEqual, 200)

			embedded := result["_embedded"].(map[string]interface{})
			records := embedded["records"].([]interface{})

			So(len(records), ShouldEqual, 4)
		})
	})
}
