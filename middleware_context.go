package horizon

import (
	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/httpx"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
)

func contextMiddleware(parent context.Context) func(c *web.C, next http.Handler) http.Handler {
	return func(c *web.C, next http.Handler) http.Handler {
		fn := func(w http.ResponseWriter, r *http.Request) {

			if _, ok := w.(http.CloseNotifier); ok {
				gctx.Set(c, httpx.CancelWhenClosed(parent, w))
			} else {
				gctx.Set(c, parent)
			}

			next.ServeHTTP(w, r)
		}
		return http.HandlerFunc(fn)
	}
}
