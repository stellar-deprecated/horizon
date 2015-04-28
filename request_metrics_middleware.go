package horizon

import (
	"github.com/zenazn/goji/web"
	"net/http"
)

type MetricsResponseWriter interface {
	Status() int
}

func newMetricsReponseWriter(parent http.ResponseWriter) MetricsResponseWriter {
	base := metricsResponseWriter{200, parent}

	if flusher, ok := parent.(http.Flusher); ok {
		return flushableMetricsResponseWriter{base, flusher}
	} else {
		return base
	}
}

// Non-flushable metrics response writer
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

func (w metricsResponseWriter) CloseNotify() <-chan bool {
	return w.ResponseWriter.(http.CloseNotifier).CloseNotify()
}

func (w metricsResponseWriter) Status() int {
	return w.status
}

// Flushable metrics response writer
type flushableMetricsResponseWriter struct {
	ResponseWriter metricsResponseWriter
	http.Flusher
}

func (w flushableMetricsResponseWriter) Header() http.Header {
	return w.ResponseWriter.Header()
}

func (w flushableMetricsResponseWriter) Write(data []byte) (int, error) {
	return w.ResponseWriter.Write(data)
}

func (w flushableMetricsResponseWriter) WriteHeader(statusCode int) {
	w.ResponseWriter.WriteHeader(statusCode)
}

func (w flushableMetricsResponseWriter) CloseNotify() <-chan bool {
	result := w.ResponseWriter.CloseNotify()
	return result
}

func (w flushableMetricsResponseWriter) Flush() {
	w.Flusher.Flush()
}

func (w flushableMetricsResponseWriter) Status() int {
	return w.ResponseWriter.status
}

// Middleware that records metrics.
//
// It records success and failures using a meter, and times every request
func requestMetricsMiddleware(c *web.C, h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app := c.Env["app"].(*App)
		mw := newMetricsReponseWriter(w)

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
