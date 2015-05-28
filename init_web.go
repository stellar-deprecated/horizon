package horizon

import (
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"

	"github.com/PuerkitoBio/throttled"
	"github.com/PuerkitoBio/throttled/store"
	"github.com/rcrowley/go-metrics"
	"github.com/rs/cors"
	"github.com/sebest/xff"
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/middleware"
)

// Web contains the http server related fields for go-horizon: the router,
// rate limiter, etc.
type Web struct {
	router      *web.Mux
	rateLimiter *throttled.Throttler

	requestTimer metrics.Timer
	failureMeter metrics.Meter
	successMeter metrics.Meter
}

// initWeb installed a new Web instance onto the provided app object.
func initWeb(app *App) {
	app.web = &Web{
		router:       web.New(),
		requestTimer: metrics.NewTimer(),
		failureMeter: metrics.NewMeter(),
		successMeter: metrics.NewMeter(),
	}
}

// initWebMiddleware installs the middleware stack used for go-horizon onto the
// provided app.
func initWebMiddleware(app *App) {
	r := app.web.router
	r.Use(middleware.EnvInit)
	r.Use(app.Middleware)
	r.Use(middleware.RequestID)
	r.Use(contextMiddleware(app.ctx))
	r.Use(xff.XFF)
	r.Use(LoggerMiddleware)
	r.Use(requestMetricsMiddleware)
	r.Use(RecoverMiddleware)
	r.Use(middleware.AutomaticOptions)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})
	r.Use(c.Handler)

	r.Use(app.web.RateLimitMiddleware)
}

// initWebActions installs the routing configuration of go-horizon onto the
// provided app.  All route registration should be implemented here.
func initWebActions(app *App) {
	r := app.web.router
	r.Get("/", rootAction)
	r.Get("/metrics", metricsAction)

	// ledger actions
	r.Get("/ledgers", ledgerIndexAction)
	r.Get("/ledgers/:id", ledgerShowAction)
	r.Get("/ledgers/:ledger_id/transactions", transactionIndexAction)
	r.Get("/ledgers/:ledger_id/operations", operationIndexAction)
	r.Get("/ledgers/:ledger_id/payments", paymentsIndexAction)
	r.Get("/ledgers/:ledger_id/effects", notImplementedAction)

	// account actions
	r.Get("/accounts", accountIndexAction)
	r.Get("/accounts/:id", accountShowAction)
	r.Get("/accounts/:account_id/transactions", transactionIndexAction)
	r.Get("/accounts/:account_id/operations", operationIndexAction)
	r.Get("/accounts/:account_id/payments", paymentsIndexAction)
	r.Get("/accounts/:account_id/effects", notImplementedAction)
	r.Get("/accounts/:account_id/offers", offerIndexAction)

	// transaction actions
	r.Get("/transactions", transactionIndexAction)
	r.Get("/transactions/:id", transactionShowAction)
	r.Get("/transactions/:tx_id/operations", operationIndexAction)
	r.Get("/transactions/:tx_id/payments", paymentsIndexAction)
	r.Get("/transactions/:tx_id/effects", notImplementedAction)

	// operation actions
	r.Get("/operations", operationIndexAction)
	r.Get("/operations/:id", notImplementedAction)
	r.Get("/operations/:op_id/effects", notImplementedAction)

	r.Get("/payments", paymentsIndexAction)

	r.Get("/offers/:id", notImplementedAction)

	// go-horizon doesn't implement everything horizon did,
	// so we reverse proxy if we can
	if app.config.RubyHorizonUrl != "" {

		u, err := url.Parse(app.config.RubyHorizonUrl)
		if err != nil {
			panic("cannot parse ruby-horizon-url")
		}

		rp := httputil.NewSingleHostReverseProxy(u)
		r.Post("/transactions", rp)
		r.Post("/friendbot", rp)
		r.Get("/friendbot", rp)
	} else {
		r.Post("/transactions", notImplementedAction)
		r.Post("/friendbot", notImplementedAction)
		r.Get("/friendbot", notImplementedAction)
	}

	r.NotFound(notFoundAction)
}

func initWebRateLimiter(app *App) {
	rateLimitStore := store.NewMemStore(1000)

	if app.redis != nil {
		rateLimitStore = store.NewRedisStore(app.redis, "throttle:", 0)
	}

	rateLimiter := throttled.RateLimit(
		app.config.RateLimit,
		&throttled.VaryBy{Custom: remoteAddrIP},
		rateLimitStore,
	)

	rateLimiter.DeniedHandler = http.HandlerFunc(rateLimitExceededAction)
	app.web.rateLimiter = rateLimiter
}

func remoteAddrIP(r *http.Request) string {
	ip := strings.SplitN(r.RemoteAddr, ":", 2)[0]
	return ip
}

func init() {
	appInit.Add(
		"web.init",
		initWeb,

		"app-context",
	)

	appInit.Add(
		"web.rate-limiter",
		initWebRateLimiter,

		"web.init",
	)
	appInit.Add(
		"web.middleware",
		initWebMiddleware,

		"web.init",
		"web.rate-limiter",
		"web.metrics",
	)
	appInit.Add(
		"web.actions",
		initWebActions,

		"web.init",
	)
}
