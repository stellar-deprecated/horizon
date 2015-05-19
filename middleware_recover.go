package horizon

import (
	"net/http"
	"runtime/debug"

	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/log"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func RecoverMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		ctx := gctx.FromC(*c)

		defer func() {
			if err := recover(); err != nil {
				log.Errorf(ctx, "panic: %+v", err)
				log.Errorf(ctx, "backtrace: %s", debug.Stack())

				//TODO: include stack trace if in debug mode
				problem.Render(gctx.FromC(*c), w, problem.ServerError)
			}
		}()

		h.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}
