package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
	"testing"
)

func TestRateLimitMiddleware(t *testing.T) {

	Convey("Rate Limiting", t, func() {
		app := NewTestApp()
		defer app.Cancel()
		rh := NewRequestHelper(app)

		Convey("sets X-RateLimit-Limit headers correctly", func() {
			w := rh.Get("/", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
			So(w.Header().Get("X-RateLimit-Limit"), ShouldEqual, "10")
		})

		Convey("Restricts based on RemoteAddr IP after too many requests", func() {
			for i := 0; i < 10; i++ {
				w := rh.Get("/", test.RequestHelperNoop)
				So(w.Code, ShouldEqual, 200)
			}

			w := rh.Get("/", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 429)

			w = rh.Get("/", test.RequestHelperRemoteAddr("127.0.0.2"))
			So(w.Code, ShouldEqual, 200)
		})

		Convey("Restrict based upon X-Forwarded-For correctly", func() {
			for i := 0; i < 10; i++ {
				w := rh.Get("/", test.RequestHelperXFF("4.4.4.4"))
				So(w.Code, ShouldEqual, 200)
			}

			w := rh.Get("/", test.RequestHelperXFF("4.4.4.4"))
			So(w.Code, ShouldEqual, 429)

			// allow other ips
			w = rh.Get("/", test.RequestHelperRemoteAddr("4.4.4.3"))
			So(w.Code, ShouldEqual, 200)

			// Ignores leading private ips
			w = rh.Get("/", test.RequestHelperXFF("10.0.0.1, 4.4.4.4"))
			So(w.Code, ShouldEqual, 429)

			// Ignores trailing ips
			w = rh.Get("/", test.RequestHelperXFF("4.4.4.4, 4.4.4.5, 127.0.0.1"))
			So(w.Code, ShouldEqual, 429)

		})
	})

	Convey("Rate Limiting works with redis", t, func() {
		c := NewTestConfig()
		c.RedisUrl = "redis://127.0.0.1:6379/"
		app, _ := NewApp(c)
		defer app.Cancel()
		rh := NewRequestHelper(app)

		redis := app.redis.Get()
		_, err := redis.Do("FLUSHDB")
		So(err, ShouldBeNil)

		for i := 0; i < 10; i++ {
			w := rh.Get("/", test.RequestHelperNoop)
			So(w.Code, ShouldEqual, 200)
		}

		w := rh.Get("/", test.RequestHelperNoop)
		So(w.Code, ShouldEqual, 429)

		w = rh.Get("/", test.RequestHelperRemoteAddr("127.0.0.2"))
		So(w.Code, ShouldEqual, 200)
	})
}
