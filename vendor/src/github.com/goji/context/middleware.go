package context

import (
	"net/http"

	"golang.org/x/net/context"

	"github.com/zenazn/goji/web"
)

// Middleware is a Goji middleware that binds a new go.net/context.Context to
// every request. This binding is two-way, and you can use the ToC and FromC
// functions to convert between one and the other.
//
// Note that since context.Context's are immutable, you will have to call Set to
// "re-bind" the request's canonical context.Context if you ever decide to
// change it, otherwise only the original context.Context (as set by this
// middleware) will be bound.
func Middleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		Set(c, context.Background())
		h.ServeHTTP(w, r)
	}
	return http.HandlerFunc(fn)
}
