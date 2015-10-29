package horizon

import (
	"fmt"
	"net/http"

	"github.com/getsentry/raven-go"
	"github.com/go-errors/errors"
	gctx "github.com/goji/context"
	"github.com/stellar/horizon/render/problem"
	"github.com/zenazn/goji/web"
)

// RecoverMiddleware helps the server recover from panics.  It ensures that
// no request can fully bring down the horizon server, and it also logs the
// panics to the logging subsystem.
func RecoverMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)

		defer func() {
			if rec := recover(); rec != nil {
				err := extractErrorFromPanic(rec)
				reportToSentry(err, r)
				problem.Render(ctx, w, err)
			}
		}()

		h.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}

func reportToSentry(err error, r *http.Request) {
	st := raven.NewStacktrace(4, 3, []string{"github.org/stellar"})
	h := raven.NewHttp(r)
	exc := raven.NewException(err, st)

	packet := raven.NewPacket(err.Error(), exc, h)
	raven.Capture(packet, nil)
}

func extractErrorFromPanic(rec interface{}) error {
	err, ok := rec.(error)
	if !ok {
		err = fmt.Errorf("%s", rec)
	}

	return errors.Wrap(err, 4)
}
