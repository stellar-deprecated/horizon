package horizon

import (
	gctx "github.com/goji/context"
	"github.com/stellar/horizon/context/requestid"
	"github.com/stellar/horizon/httpx"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
)

func contextMiddleware(parent context.Context) func(c *web.C, next http.Handler) http.Handler {
	return func(c *web.C, next http.Handler) http.Handler {
		fn := func(w http.ResponseWriter, r *http.Request) {
			ctx := parent
			ctx = requestid.ContextFromC(ctx, c)

			// establish "cancel on close" context if possible
			if _, ok := w.(http.CloseNotifier); ok {
				ctx = httpx.CancelWhenClosed(ctx, w)
			}

			gctx.Set(c, ctx)
			next.ServeHTTP(w, r)
		}
		return http.HandlerFunc(fn)
	}
}
