package horizon

import (
	"fmt"
	"net/http"
	"runtime"

	"github.com/Sirupsen/logrus"
	"github.com/garyburd/redigo/redis"
	"github.com/jmoiron/sqlx"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-stellar-base/build"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/pump"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/txsub"
	"github.com/zenazn/goji/bind"
	"github.com/zenazn/goji/graceful"
	"golang.org/x/net/context"
)

var appContextKey = 0

// You can override this variable using: gb build -ldflags "-X main.version aabbccdd"
var version = ""

type App struct {
	config            Config
	web               *Web
	historyDb         *sqlx.DB
	coreDb            *sqlx.DB
	ctx               context.Context
	cancel            func()
	redis             *redis.Pool
	log               *logrus.Entry
	logMetrics        *log.Metrics
	coreVersion       string
	horizonVersion    string
	networkPassphrase string
	submitter         *txsub.System
	pump              *pump.Pump
	paths             paths.Finder

	// metrics
	metrics                metrics.Registry
	horizonLedgerGauge     metrics.Gauge
	stellarCoreLedgerGauge metrics.Gauge
	horizonConnGauge       metrics.Gauge
	stellarCoreConnGauge   metrics.Gauge
	goroutineGauge         metrics.Gauge

	// cached state
	latestLedgerState db.LedgerState
}

func SetVersion(v string) {
	version = v
}

// AppFromContext retrieves a *App from the context tree.
func AppFromContext(ctx context.Context) (*App, bool) {
	a, ok := ctx.Value(&appContextKey).(*App)
	return a, ok
}

// NewApp constructs an new App instance from the provided config.
func NewApp(config Config) (*App, error) {

	result := &App{config: config}
	result.horizonVersion = version
	result.networkPassphrase = build.DefaultNetwork.Passphrase
	appInit.Run(result)

	return result, nil
}

// Serve starts the horizon system, binding it to a socket, setting up
// the shutdown signals and starting the appropriate db-streaming pumps.
func (a *App) Serve() {

	a.web.router.Compile()
	http.Handle("/", a.web.router)

	listenStr := fmt.Sprintf(":%d", a.config.Port)
	listener := bind.Socket(listenStr)
	log.Infof(a.ctx, "Starting horizon on %s", listener.Addr())

	graceful.HandleSignals()
	bind.Ready()
	graceful.PreHook(func() {
		log.Info(a.ctx, "received signal, gracefully stopping")
		a.Cancel()
	})
	graceful.PostHook(func() {
		log.Info(a.ctx, "stopped")
	})

	sse.SetPump(a.ctx, a.pump.Subscribe())

	err := graceful.Serve(listener, http.DefaultServeMux)

	if err != nil {
		log.Panic(a.ctx, err)
	}

	graceful.Wait()
}

// Cancel triggers the app's cancellation signal, which will trigger the shutdown
// of all child subsystems.  Note connections to external systems (such as db
// connections) are not closed.  Use `Close()` to force immediate closure of
// those resources
func (a *App) Cancel() {
	a.cancel()
}

// Close cancels the app and forces the closure of db connections
func (a *App) Close() {
	a.Cancel()
	a.historyDb.Close()
	a.coreDb.Close()
}

// HistoryQuery returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the history database
func (a *App) HistoryQuery() db.SqlQuery {
	return db.SqlQuery{DB: a.historyDb}
}

// CoreQuery returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the connected stellar core database
func (a *App) CoreQuery() db.SqlQuery {
	return db.SqlQuery{DB: a.coreDb}
}

// UpdateMetrics triggers a refresh of several metrics gauges, such as open
// db connections and ledger state
func (a *App) UpdateLedgerState() {
	var ls db.LedgerState
	q := db.LedgerStateQuery{a.HistoryQuery(), a.CoreQuery()}
	err := db.Get(a.ctx, q, &ls)

	if err != nil {
		log.WithStack(a.ctx, err).
			WithField("err", err.Error()).
			Error("failed to load ledger state")
		return
	}

	a.latestLedgerState = ls
}

// UpdateMetrics triggers a refresh of several metrics gauges, such as open
// db connections and ledger state
func (a *App) UpdateMetrics(ctx context.Context) {
	a.UpdateLedgerState()

	a.goroutineGauge.Update(int64(runtime.NumGoroutine()))

	a.horizonLedgerGauge.Update(int64(a.latestLedgerState.HorizonSequence))
	a.stellarCoreLedgerGauge.Update(int64(a.latestLedgerState.StellarCoreSequence))

	a.horizonConnGauge.Update(int64(a.historyDb.Stats().OpenConnections))
	a.stellarCoreConnGauge.Update(int64(a.coreDb.Stats().OpenConnections))
}
