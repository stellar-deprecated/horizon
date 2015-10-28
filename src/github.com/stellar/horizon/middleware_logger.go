package horizon

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	gctx "github.com/goji/context"
	"github.com/stellar/horizon/log"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/mutil"
)

// LoggerMiddleware is the middleware that logs http requests and resposnes
// to the logging subsytem of horizon.
func LoggerMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)
		mw := mutil.WrapWriter(w)

		logStartOfRequest(ctx, r)

		then := time.Now()
		h.ServeHTTP(mw, r)
		duration := time.Now().Sub(then)

		logEndOfRequest(ctx, duration, mw)
	}

	return http.HandlerFunc(fn)
}

func logStartOfRequest(ctx context.Context, r *http.Request) {
	log.Ctx(ctx).WithFields(log.F{
		"path":   r.URL.String(),
		"method": r.Method,
	}).Info("Starting request")
}

func logEndOfRequest(ctx context.Context, duration time.Duration, mw mutil.WriterProxy) {
	log.Ctx(ctx).WithFields(log.F{
		"status":   mw.Status(),
		"bytes":    mw.BytesWritten(),
		"duration": duration,
	}).Info("Finished request")
}
