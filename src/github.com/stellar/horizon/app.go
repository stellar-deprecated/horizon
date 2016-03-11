package horizon

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"runtime"
	"time"

	"github.com/garyburd/redigo/redis"
	"github.com/jmoiron/sqlx"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-stellar-base/build"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/queries/core"
	"github.com/stellar/horizon/db/queries/history"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/friendbot"
	"github.com/stellar/horizon/ingest"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/pump"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/txsub"
	"golang.org/x/net/context"
	"golang.org/x/net/http2"
	"gopkg.in/tylerb/graceful.v1"
)

var appContextKey = 0

// You can override this variable using: gb build -ldflags "-X main.version aabbccdd"
var version = ""

// App represents the root of the state of a horizon instance.
type App struct {
	config            Config
	web               *Web
	horizonDb         *sqlx.DB
	coreDb            *sqlx.DB
	ctx               context.Context
	cancel            func()
	redis             *redis.Pool
	coreVersion       string
	horizonVersion    string
	networkPassphrase string
	submitter         *txsub.System
	pump              *pump.Pump
	paths             paths.Finder
	friendbot         *friendbot.Bot
	ingester          *ingest.Ingester

	// metrics
	metrics                metrics.Registry
	horizonLedgerGauge     metrics.Gauge
	stellarCoreLedgerGauge metrics.Gauge
	horizonConnGauge       metrics.Gauge
	stellarCoreConnGauge   metrics.Gauge
	goroutineGauge         metrics.Gauge

	// cached state
	latestLedgerState struct {
		Core    int32
		Horizon int32
	}
}

// SetVersion records the provided version string in the package level `version`
// var, which will be used for the reported horizon version.
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
	result.init()
	return result, nil
}

// Init initializes app, using the config to populate db connections and
// whatnot.
func (a *App) init() {
	appInit.Run(a)
}

// Serve starts the horizon system, binding it to a socket, setting up
// the shutdown signals and starting the appropriate db-streaming pumps.
func (a *App) Serve() {

	a.web.router.Compile()
	http.Handle("/", a.web.router)

	addr := fmt.Sprintf(":%d", a.config.Port)

	srv := &graceful.Server{
		Timeout: 10 * time.Second,

		Server: &http.Server{
			Addr:    addr,
			Handler: http.DefaultServeMux,
		},

		ShutdownInitiated: func() {
			log.Info("received signal, gracefully stopping")
			a.Close()
		},
	}

	http2.ConfigureServer(srv.Server, nil)

	sse.SetPump(a.pump.Subscribe())

	log.Infof("Starting horizon on %s", addr)

	var err error
	if a.config.TLSCert != "" {
		err = srv.ListenAndServeTLS(a.config.TLSCert, a.config.TLSKey)
	} else {
		err = srv.ListenAndServe()
	}

	if err != nil {
		log.Panic(err)
	}

	log.Info("stopped")
}

// Close cancels the app and forces the closure of db connections
func (a *App) Close() {
	a.cancel()

	if a.ingester != nil {
		a.ingester.Close()
	}

	a.horizonDb.Close()
	a.coreDb.Close()
}

func (a *App) HistoryQ() *history.Q {
	// TODO: store a *history.Q on app
	return &history.Q{a.HorizonRepo(nil)}
}

func (a *App) HorizonRepo(ctx context.Context) *db2.Repo {
	return &db2.Repo{DB: a.horizonDb, Ctx: ctx}
}

// HorizonQuery returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the horizon database
func (a *App) HorizonQuery() db.SqlQuery {
	return db.SqlQuery{DB: a.horizonDb}
}

func (a *App) CoreRepo(ctx context.Context) *db2.Repo {
	return &db2.Repo{DB: a.coreDb, Ctx: ctx}
}

func (a *App) CoreQ() *core.Q {
	// TODO: store a *core.Q on app
	return &core.Q{a.CoreRepo(nil)}
}

// CoreQuery returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the connected stellar core database
func (a *App) CoreQuery() db.SqlQuery {
	return db.SqlQuery{DB: a.coreDb}
}

// UpdateLedgerState triggers a refresh of several metrics gauges, such as open
// db connections and ledger state
func (a *App) UpdateLedgerState() {
	var err error

	err = a.CoreQ().LatestLedger(&a.latestLedgerState.Core)
	if err != nil {
		goto Failed
	}

	err = a.HistoryQ().LatestLedger(&a.latestLedgerState.Horizon)
	if err != nil {
		goto Failed
	}

	return

Failed:
	log.WithStack(err).
		WithField("err", err.Error()).
		Error("failed to load ledger state")

}

// UpdateStellarCoreInfo updates the value of coreVersion and networkPassphrase
// from the Stellar core API.
func (a *App) UpdateStellarCoreInfo() {
	if a.config.StellarCoreURL == "" {
		return
	}

	fail := func(err error) {
		log.Warnf("could not load stellar-core info: %s", err)
	}

	resp, err := http.Get(fmt.Sprint(a.config.StellarCoreURL, "/info"))

	if err != nil {
		fail(err)
		return
	}

	defer resp.Body.Close()
	contents, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fail(err)
		return
	}

	var responseJSON map[string]*json.RawMessage
	err = json.Unmarshal(contents, &responseJSON)
	if err != nil {
		fail(err)
		return
	}

	var serverInfo map[string]interface{}
	err = json.Unmarshal(*responseJSON["info"], &serverInfo)
	if err != nil {
		fail(err)
		return
	}

	// TODO: make resilient to changes in stellar-core's info output
	a.coreVersion = serverInfo["build"].(string)
	a.networkPassphrase = serverInfo["network"].(string)
}

// UpdateMetrics triggers a refresh of several metrics gauges, such as open
// db connections and ledger state
func (a *App) UpdateMetrics(ctx context.Context) {
	a.UpdateLedgerState()

	a.goroutineGauge.Update(int64(runtime.NumGoroutine()))

	a.horizonLedgerGauge.Update(int64(a.latestLedgerState.Horizon))
	a.stellarCoreLedgerGauge.Update(int64(a.latestLedgerState.Core))

	a.horizonConnGauge.Update(int64(a.horizonDb.Stats().OpenConnections))
	a.stellarCoreConnGauge.Update(int64(a.coreDb.Stats().OpenConnections))
}
