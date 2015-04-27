package horizon

import (
	"./test"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRootAction(t *testing.T) {

	Convey("GET /", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()

		r, _ := http.NewRequest("GET", "/", nil)
		w := httptest.NewRecorder()
		c := web.C{
			Env: map[interface{}]interface{}{},
		}

		app.web.router.ServeHTTPC(c, w, r)

		So(w.Code, ShouldEqual, 200)
	})
}
