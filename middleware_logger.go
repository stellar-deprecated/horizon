package horizon

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/log"
	"github.com/zenazn/goji/web"
)

// LoggerMiddleware is the middleware that logs http requests and resposnes
// to the logging subsytem of go-horizon.
func LoggerMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)

		logStartOfRequest(ctx, r)

		then := time.Now()
		h.ServeHTTP(w, r)
		duration := time.Now().Sub(then)
		log.WithField(ctx, "duration", duration).Info("Finished request")
		_ = duration
	}

	return http.HandlerFunc(fn)
}

func logStartOfRequest(ctx context.Context, r *http.Request) {
	log.Warn(ctx, "Starting request")
	// TODO: log parameters here
}
