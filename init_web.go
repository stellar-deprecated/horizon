package horizon

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/PuerkitoBio/throttled/store"
	"github.com/rcrowley/go-metrics"
	"github.com/rs/cors"
	"github.com/sebest/xff"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/middleware"
	"net/http"
	"strings"
)

type Web struct {
	router      *web.Mux
	rateLimiter *throttled.Throttler

	requestTimer metrics.Timer
	failureMeter metrics.Meter
	successMeter metrics.Meter
}

func initWeb(app *App) {
	app.web = &Web{
		router:       web.New(),
		requestTimer: metrics.NewTimer(),
		failureMeter: metrics.NewMeter(),
		successMeter: metrics.NewMeter(),
	}
}

func initWebMetrics(app *App) {
	app.metrics.Register("requests.total", app.web.requestTimer)
	app.metrics.Register("requests.succeeded", app.web.successMeter)
	app.metrics.Register("requests.failed", app.web.failureMeter)
}

func initWebMiddleware(app *App) {
	app.web.router.Use(middleware.EnvInit)
	app.web.router.Use(middleware.RequestID)
	app.web.router.Use(xff.XFF)
	app.web.router.Use(app.Middleware)
	app.web.router.Use(middleware.Logger)
	app.web.router.Use(RecoverMiddleware)
	app.web.router.Use(middleware.AutomaticOptions)
	app.web.router.Use(requestMetricsMiddleware)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})
	app.web.router.Use(c.Handler)

	app.web.router.Use(app.web.RateLimitMiddleware)
}

func initWebActions(app *App) {
	app.web.router.Get("/", rootAction)
	app.web.router.Get("/metrics", metricsAction)

	// ledger actions
	app.web.router.Get("/ledgers", ledgerIndexAction)
	app.web.router.Get("/ledgers/:id", ledgerShowAction)
	app.web.router.Get("/ledgers/:ledger_id/transactions", notImplementedAction)
	app.web.router.Get("/ledgers/:ledger_id/operations", notImplementedAction)
	app.web.router.Get("/ledgers/:ledger_id/effects", notImplementedAction)

	// account actions
	app.web.router.Get("/accounts", notImplementedAction)
	app.web.router.Get("/accounts/:id", accountShowAction)
	app.web.router.Get("/accounts/:account_id/transactions", notImplementedAction)
	app.web.router.Get("/accounts/:account_id/operations", notImplementedAction)
	app.web.router.Get("/accounts/:account_id/effects", notImplementedAction)

	// transaction actions
	app.web.router.Get("/transactions", transactionIndexAction)
	app.web.router.Get("/transactions/:id", transactionShowAction)
	app.web.router.Get("/transactions/:tx_id/operations", notImplementedAction)
	app.web.router.Get("/transactions/:tx_id/effects", notImplementedAction)

	// transaction actions
	app.web.router.Get("/operations", notImplementedAction)
	app.web.router.Get("/operations/:id", notImplementedAction)
	app.web.router.Get("/operations/:tx_id/effects", notImplementedAction)

	app.web.router.NotFound(notFoundAction)
}

func initWebRateLimiter(app *App) {
	rateLimitStore := store.NewMemStore(1000)

	if app.redis != nil {
		rateLimitStore = store.NewRedisStore(app.redis, "throttle:", 0)
	}

	rateLimiter := throttled.RateLimit(
		app.config.RateLimit,
		&throttled.VaryBy{Custom: remoteAddrIp},
		rateLimitStore,
	)
	rateLimiter.DeniedHandler = http.HandlerFunc(rateLimitExceededAction)
	app.web.rateLimiter = rateLimiter
}

func remoteAddrIp(r *http.Request) string {
	ip := strings.SplitN(r.RemoteAddr, ":", 2)[0]
	return ip
}
