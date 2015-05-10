package horizon

import (
	"github.com/zenazn/goji/web"
	"net/http"
)

func (web *Web) RateLimitMiddleware(c *web.C, next http.Handler) http.Handler {
	return web.rateLimiter.Throttle(next)
}
