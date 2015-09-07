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
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/problem"
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

	// register problems
	problem.RegisterError(db.ErrNoResults, problem.NotFound)
}

// initWebMiddleware installs the middleware stack used for go-horizon onto the
// provided app.
func initWebMiddleware(app *App) {

	r := app.web.router
	r.Use(stripTrailingSlashMiddleware())
	r.Use(middleware.EnvInit)
	r.Use(app.Middleware)
	r.Use(middleware.RequestID)
	r.Use(contextMiddleware(app.ctx))
	r.Use(xff.Handler)
	r.Use(LoggerMiddleware)
	r.Use(requestMetricsMiddleware)
	r.Use(RecoverMiddleware)
	r.Use(middleware.AutomaticOptions)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedHeaders: []string{"*"},
	})
	r.Use(c.Handler)

	r.Use(app.web.RateLimitMiddleware)
}

// initWebActions installs the routing configuration of go-horizon onto the
// provided app.  All route registration should be implemented here.
func initWebActions(app *App) {
	r := app.web.router
	r.Get("/", &RootAction{})
	r.Get("/metrics", &MetricsAction{})

	// ledger actions
	r.Get("/ledgers", &LedgerIndexAction{})
	r.Get("/ledgers/:id", &LedgerShowAction{})
	r.Get("/ledgers/:ledger_id/transactions", &TransactionIndexAction{})
	r.Get("/ledgers/:ledger_id/operations", &OperationIndexAction{})
	r.Get("/ledgers/:ledger_id/payments", &PaymentsIndexAction{})
	r.Get("/ledgers/:ledger_id/effects", &EffectIndexAction{})

	// account actions
	r.Get("/accounts", &AccountIndexAction{})
	r.Get("/accounts/:id", &AccountShowAction{})
	r.Get("/accounts/:account_id/transactions", &TransactionIndexAction{})
	r.Get("/accounts/:account_id/operations", &OperationIndexAction{})
	r.Get("/accounts/:account_id/payments", &PaymentsIndexAction{})
	r.Get("/accounts/:account_id/effects", &EffectIndexAction{})
	r.Get("/accounts/:account_id/offers", &OffersByAccountAction{})

	// transaction actions
	r.Get("/transactions", &TransactionIndexAction{})
	r.Get("/transactions/:id", &TransactionShowAction{})
	r.Get("/transactions/:tx_id/operations", &OperationIndexAction{})
	r.Get("/transactions/:tx_id/payments", &PaymentsIndexAction{})
	r.Get("/transactions/:tx_id/effects", &EffectIndexAction{})

	// operation actions
	r.Get("/operations", &OperationIndexAction{})
	r.Get("/operations/:id", &OperationShowAction{})
	r.Get("/operations/:op_id/effects", &EffectIndexAction{})

	r.Get("/payments", &PaymentsIndexAction{})
	r.Get("/effects", &EffectIndexAction{})

	r.Get("/offers/:id", &NotImplementedAction{})
	r.Get("/order_book", &OrderBookShowAction{})

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
		r.Post("/transactions", &NotImplementedAction{})
		r.Post("/friendbot", &NotImplementedAction{})
		r.Get("/friendbot", &NotImplementedAction{})
	}

	r.NotFound(&NotFoundAction{})
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

	rateLimiter.DeniedHandler = &RateLimitExceededAction{App: app, Action: Action{}}
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
