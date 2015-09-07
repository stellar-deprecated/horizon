package horizon

import (
	"net/http"
	"reflect"
	"testing"

	"github.com/Sirupsen/logrus"
	"github.com/Sirupsen/logrus/hooks/sentry"
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

	Convey("NewApp adds a sentry hook when the provided config's SentryDSN is valid", t, func() {
		config := NewTestConfig()
		config.SentryDSN = "https://3848836eb8b040c5b7cabb7b52a7108f:874506085e38486ea7a5a06f56046601@app.getsentry.com/44303"
		app, _ := NewApp(config)
		defer app.Close()

		// we have to use reflection to see if the hook is added :(
		r := reflect.ValueOf(app.log.Logger.Hooks)

		So(r.Kind(), ShouldEqual, reflect.Map)

		expectations := []struct {
			Level     logrus.Level
			Assertion func(actual interface{}, options ...interface{}) string
		}{
			{logrus.DebugLevel, shouldNotHaveASentryHook},
			{logrus.InfoLevel, shouldNotHaveASentryHook},
			{logrus.WarnLevel, shouldNotHaveASentryHook},
			{logrus.ErrorLevel, shouldHaveASentryHook},
			{logrus.PanicLevel, shouldHaveASentryHook},
			{logrus.FatalLevel, shouldHaveASentryHook},
		}

		for _, expectation := range expectations {
			hooks := r.MapIndex(reflect.ValueOf(expectation.Level)).Interface()
			So(hooks, expectation.Assertion)
		}
	})

	Convey("NewApp does not add a sentry hook if config's SentryDSN is empty", t, func() {
		config := NewTestConfig()
		config.SentryDSN = ""
		app, _ := NewApp(config)
		defer app.Close()

		// we have to use reflection to see if the hook is added :(
		r := reflect.ValueOf(app.log.Logger.Hooks)
		So(r.Kind(), ShouldEqual, reflect.Map)

		expectations := []struct {
			Level     logrus.Level
			Assertion func(actual interface{}, options ...interface{}) string
		}{
			{logrus.DebugLevel, shouldNotHaveASentryHook},
			{logrus.InfoLevel, shouldNotHaveASentryHook},
			{logrus.WarnLevel, shouldNotHaveASentryHook},
			{logrus.ErrorLevel, shouldNotHaveASentryHook},
			{logrus.PanicLevel, shouldNotHaveASentryHook},
			{logrus.FatalLevel, shouldNotHaveASentryHook},
		}

		for _, expectation := range expectations {
			hooksv := r.MapIndex(reflect.ValueOf(expectation.Level))
			var hooks []logrus.Hook

			if hooksv.IsValid() {
				hooks = hooksv.Interface().([]logrus.Hook)
			} else {
				hooks = nil
			}

			So(hooks, expectation.Assertion)
		}
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

		w := rh.Get("/accounts", test.RequestHelperNoop)
		So(w.Code, ShouldEqual, 200)

		w = rh.Get("/accounts/", test.RequestHelperNoop)
		So(w.Code, ShouldEqual, 200)

	})
}

func shouldHaveASentryHook(actual interface{}, options ...interface{}) string {
	if actual == nil {
		return "No sentry hook found"
	}

	hooks := actual.([]logrus.Hook)

	for _, hook := range hooks {
		_, ok := hook.(*logrus_sentry.SentryHook)
		if ok {
			return ""
		}
	}

	return "No sentry hook found"
}

func shouldNotHaveASentryHook(actual interface{}, options ...interface{}) string {
	if actual == nil {
		return ""
	}

	hooks := actual.([]logrus.Hook)

	for _, hook := range hooks {
		_, ok := hook.(*logrus_sentry.SentryHook)
		if ok {
			return "Sentry hook found, but we expect none"
		}
	}

	return ""
}
