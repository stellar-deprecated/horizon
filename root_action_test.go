package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestRootAction(t *testing.T) {

	Convey("GET /", t, func() {
		databaseUrl := os.Getenv("DATABASE_URL")
		if databaseUrl == "" {
			databaseUrl = "postgres://localhost:5432/horizon_test?sslmode=disable"
		}

		app, err := NewApp(Config{
			DatabaseUrl: databaseUrl,
		})
		So(err, ShouldBeNil)

		r, _ := http.NewRequest("GET", "/", nil)
		w := httptest.NewRecorder()
		c := web.C{
			Env: map[interface{}]interface{}{},
		}

		app.web.router.ServeHTTPC(c, w, r)

		So(w.Code, ShouldEqual, 200)
	})
}
