package horizon

import (
	gctx "github.com/goji/context"
	"github.com/stellar/horizon/pkg/context/requestid"
	"github.com/stellar/horizon/pkg/httpx"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
)

func contextMiddleware(parent context.Context) func(c *web.C, next http.Handler) http.Handler {
	return func(c *web.C, next http.Handler) http.Handler {
		fn := func(w http.ResponseWriter, r *http.Request) {
			ctx := parent
			ctx = requestid.ContextFromC(ctx, c)
			ctx, cancel := httpx.RequestContext(ctx, w, r)

			gctx.Set(c, ctx)
			defer cancel()
			next.ServeHTTP(w, r)
		}
		return http.HandlerFunc(fn)
	}
}
