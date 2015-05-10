package horizon

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/rcrowley/go-metrics"
	"github.com/rs/cors"
	"github.com/sebest/xff"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/middleware"
)

type Web struct {
	router      *web.Mux
	rateLimiter *throttled.Throttler

	requestTimer metrics.Timer
	failureMeter metrics.Meter
	successMeter metrics.Meter
}

func NewWeb(app *App) {

	api := web.New()

	result := Web{
		router:       api,
		requestTimer: metrics.NewTimer(),
		failureMeter: metrics.NewMeter(),
		successMeter: metrics.NewMeter(),
	}
	app.web = &result

	app.metrics.Register("requests.total", result.requestTimer)
	app.metrics.Register("requests.succeeded", result.successMeter)
	app.metrics.Register("requests.failed", result.failureMeter)

	installRateLimiter(&result, app)
	installMiddleware(api, app)
	installActions(api)
}

func installMiddleware(api *web.Mux, app *App) {
	api.Use(middleware.EnvInit)
	api.Use(middleware.RequestID)
	api.Use(xff.XFF)
	api.Use(app.Middleware)
	api.Use(middleware.Logger)
	api.Use(RecoverMiddleware)
	api.Use(middleware.AutomaticOptions)
	api.Use(requestMetricsMiddleware)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})
	api.Use(c.Handler)

	api.Use(app.web.RateLimitMiddleware)
}

func installActions(api *web.Mux) {
	api.Get("/", rootAction)
	api.Get("/metrics", metricsAction)

	// ledger actions
	api.Get("/ledgers", ledgerIndexAction)
	api.Get("/ledgers/:id", ledgerShowAction)
	api.Get("/ledgers/:ledger_id/transactions", notImplementedAction)
	api.Get("/ledgers/:ledger_id/operations", notImplementedAction)
	api.Get("/ledgers/:ledger_id/effects", notImplementedAction)

	// account actions
	api.Get("/accounts", notImplementedAction)
	api.Get("/accounts/:id", accountShowAction)
	api.Get("/accounts/:account_id/transactions", notImplementedAction)
	api.Get("/accounts/:account_id/operations", notImplementedAction)
	api.Get("/accounts/:account_id/effects", notImplementedAction)

	// transaction actions
	api.Get("/transactions", notImplementedAction)
	api.Get("/transactions/:id", notImplementedAction)
	api.Get("/transactions/:tx_id/operations", notImplementedAction)
	api.Get("/transactions/:tx_id/effects", notImplementedAction)

	// transaction actions
	api.Get("/operations", notImplementedAction)
	api.Get("/operations/:id", notImplementedAction)
	api.Get("/operations/:tx_id/effects", notImplementedAction)

	api.NotFound(notFoundAction)
}
