package horizon

import (
	"net/http"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestApp(t *testing.T) {
	Convey("NewApp establishes the app in its context", t, func() {
		app, err := NewApp(NewTestConfig())
		So(err, ShouldBeNil)
		defer app.Close()

		found, ok := AppFromContext(app.ctx)
		So(ok, ShouldBeTrue)
		So(found, ShouldEqual, app)
	})

	Convey("NewApp panics if the provided config's SentryDSN is invalid", t, func() {
		config := NewTestConfig()
		config.SentryDSN = "Not a url"

		So(func() {
			app, _ := NewApp(config)
			app.Close()
		}, ShouldPanic)
	})

	Convey("CORS support", t, func() {
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		w := rh.Get("/", test.RequestHelperNoop)

		So(w.Code, ShouldEqual, 200)
		So(w.HeaderMap.Get("Access-Control-Allow-Origin"), ShouldEqual, "")

		w = rh.Get("/", func(r *http.Request) {
			r.Header.Set("Origin", "somewhere.com")
		})

		So(w.Code, ShouldEqual, 200)
		So(w.HeaderMap.Get("Access-Control-Allow-Origin"), ShouldEqual, "somewhere.com")

	})

	Convey("Trailing slash causes redirect", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Close()
		rh := NewRequestHelper(app)

		w := rh.Get("/ledgers", test.RequestHelperNoop)
		So(w.Code, ShouldEqual, 200)

		w = rh.Get("/ledgers/", test.RequestHelperNoop)
		So(w.Code, ShouldEqual, 200)

	})

	Convey("app.UpdateMetrics", t, func() {
		test.LoadScenario("base")
		app := NewTestApp()
		defer app.Close()
		So(app.horizonLatestLedgerGauge.Value(), ShouldEqual, 0)
		So(app.coreLatestLedgerGauge.Value(), ShouldEqual, 0)

		app.UpdateMetrics(test.Context())

		So(app.horizonLatestLedgerGauge.Value(), ShouldEqual, 3)
		So(app.coreLatestLedgerGauge.Value(), ShouldEqual, 3)
	})
}
