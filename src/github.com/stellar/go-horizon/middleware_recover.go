package horizon

import (
	"net/http"
	"runtime"

	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/log"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

// RecoverMiddleware helps the server recover from panics.  It ensures that
// no request can fully bring down the horizon server, and it also logs the
// panics to the logging subsystem.
func RecoverMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)

		defer func() {
			if err := recover(); err != nil {
				stack := make([]byte, 4096) // 4k of stack should be sufficient to see the source
				n := runtime.Stack(stack, false)

				log.
					WithField(ctx, "stacktrace", string(stack[:n])).
					Errorf("panic: %+v", err)

				//TODO: include stack trace if in debug mode
				problem.Render(gctx.FromC(*c), w, problem.ServerError)
			}
		}()

		h.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}
