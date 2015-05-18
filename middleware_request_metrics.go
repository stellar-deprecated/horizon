package horizon

import (
	"net/http"

	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/mutil"
)

// Middleware that records metrics.
//
// It records success and failures using a meter, and times every request
func requestMetricsMiddleware(c *web.C, h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app := c.Env["app"].(*App)
		mw := mutil.WrapWriter(w)

		app.web.requestTimer.Time(func() {
			h.ServeHTTP(mw.(http.ResponseWriter), r)
		})

		if 200 <= mw.Status() && mw.Status() < 400 {
			// a success is in [200, 400)
			app.web.successMeter.Mark(1)
		} else if 400 <= mw.Status() && mw.Status() < 600 {
			// a success is in [400, 600)
			app.web.failureMeter.Mark(1)
		}

	})
}
