package horizon

import (
	"github.com/zenazn/goji/web"
	"net/http"
)

//
type metricsResponseWriter struct {
	status int
	http.ResponseWriter
}

func (w metricsResponseWriter) Header() http.Header {
	return w.ResponseWriter.Header()
}

func (w metricsResponseWriter) Write(data []byte) (int, error) {
	return w.ResponseWriter.Write(data)
}

func (w metricsResponseWriter) WriteHeader(statusCode int) {
	w.status = statusCode
	w.ResponseWriter.WriteHeader(statusCode)
}

func requestMetricsMiddleware(c *web.C, h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app := c.Env["app"].(*App)
		mw := metricsResponseWriter{200, w}

		app.web.requestTimer.Time(func() {
			h.ServeHTTP(mw, r)
		})

		if 200 <= mw.status && mw.status < 400 {
			// a success is in [200, 400)
			app.web.successMeter.Mark(1)
		} else if 400 <= mw.status && mw.status < 600 {
			// a success is in [400, 600)
			app.web.failureMeter.Mark(1)
		}

	})
}
