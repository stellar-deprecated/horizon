package horizon

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/PuerkitoBio/throttled/store"
	"github.com/zenazn/goji/web"
	"net/http"
	"strings"
)

func (web *Web) RateLimitMiddleware(c *web.C, next http.Handler) http.Handler {
	return web.rateLimiter.Throttle(next)
}

func installRateLimiter(web *Web, app *App) {
	rateLimitStore := store.NewMemStore(1000)

	if app.redis != nil {
		rateLimitStore = store.NewRedisStore(app.redis, "throttle:", 0)
	}

	rateLimiter := throttled.RateLimit(
		app.config.RateLimit,
		&throttled.VaryBy{Custom: remoteAddrIp},
		rateLimitStore,
	)

	web.rateLimiter = rateLimiter
}

func remoteAddrIp(r *http.Request) string {
	ip := strings.SplitN(r.RemoteAddr, ":", 2)[0]
	return ip
}
