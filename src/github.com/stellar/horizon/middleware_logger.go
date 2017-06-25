package horizon

import (
	"net/http"
	"strings"
	"time"

	"golang.org/x/net/context"

	gctx "github.com/goji/context"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/render"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/middleware"
	"github.com/zenazn/goji/web/mutil"
)

// LoggerMiddleware is the middleware that logs http requests and resposnes
// to the logging subsytem of horizon.
func LoggerMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)
		mw := mutil.WrapWriter(w)

		logger := log.WithField("req", middleware.GetReqID(*c))

		ctx = log.Set(ctx, logger)
		gctx.Set(c, ctx)

		logStartOfRequest(ctx, r)

		then := time.Now()
		h.ServeHTTP(mw, r)
		duration := time.Now().Sub(then)
		// Checking `Accept` header from user request because if the streaming connection
		// is reset before sending the first event no Content-Type header is sent in a response.
		acceptHeader := r.Header.Get("Accept")
		streaming := strings.Contains(acceptHeader, render.MimeEventStream)
		logEndOfRequest(ctx, r, duration, mw, streaming)
	}

	return http.HandlerFunc(fn)
}

func logStartOfRequest(ctx context.Context, r *http.Request) {
	log.Ctx(ctx).WithFields(log.F{
		"path":   r.URL.String(),
		"method": r.Method,
		"ip":     r.RemoteAddr,
		"host":   r.Host,
	}).Info("Starting request")
}

func logEndOfRequest(ctx context.Context, r *http.Request, duration time.Duration, mw mutil.WriterProxy, streaming bool) {
	log.Ctx(ctx).WithFields(log.F{
		"path":      r.URL.String(),
		"method":    r.Method,
		"ip":        r.RemoteAddr,
		"host":      r.Host,
		"status":    mw.Status(),
		"bytes":     mw.BytesWritten(),
		"duration":  duration,
		"streaming": streaming,
	}).Info("Finished request")
}
