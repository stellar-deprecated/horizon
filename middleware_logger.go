package horizon

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/log"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/mutil"
)

// LoggerMiddleware is the middleware that logs http requests and resposnes
// to the logging subsytem of go-horizon.
func LoggerMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)
		mw := mutil.WrapWriter(w)

		logStartOfRequest(ctx, r)

		then := time.Now()
		h.ServeHTTP(mw, r)
		duration := time.Now().Sub(then)

		logEndOfRequest(ctx, duration, mw)

		_ = duration
	}

	return http.HandlerFunc(fn)
}

func logStartOfRequest(ctx context.Context, r *http.Request) {
	fields := log.Fields{
		"path":   r.URL.String(),
		"method": r.Method,
	}

	log.WithFields(ctx, fields).Info("Starting request")
}

func logEndOfRequest(ctx context.Context, duration time.Duration, mw mutil.WriterProxy) {
	fields := log.Fields{
		"status":   mw.Status(),
		"bytes":    mw.BytesWritten(),
		"duration": duration,
	}

	log.WithFields(ctx, fields).Info("Finished request")
}
