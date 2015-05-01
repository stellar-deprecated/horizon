package horizon

import (
	"github.com/zenazn/goji/web"
	"net/http"
)

// Adds the "app" env key into every request, so that subsequence middleware
// or handlers can retrieve a horizon.App instance
func (app *App) Middleware(c *web.C, h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		c.Env["app"] = app
		h.ServeHTTP(w, r)
	})
}
