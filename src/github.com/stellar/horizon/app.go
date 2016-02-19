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
	"github.com/stellar/horizon/friendbot"
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

type App struct {
	config            Config
	web               *Web
	historyDb         *sqlx.DB
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
	err := db.Get(context.Background(), q, &ls)

	if err != nil {
		log.WithStack(err).
			WithField("err", err.Error()).
			Error("failed to load ledger state")
		return
	}

	a.latestLedgerState = ls
}

// UpdateCoreVersion updates the value of coreVersion from the Stellar core API
func (a *App) UpdateStellarCoreInfo() {
	if a.config.StellarCoreUrl == "" {
		return
	}

	fail := func(err error) {
		log.Warnf("could not load stellar-core info: %s", err)
	}

	resp, err := http.Get(fmt.Sprint(a.config.StellarCoreUrl, "/info"))

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

	var responseJson map[string]*json.RawMessage
	err = json.Unmarshal(contents, &responseJson)
	if err != nil {
		fail(err)
		return
	}

	var serverInfo map[string]interface{}
	err = json.Unmarshal(*responseJson["info"], &serverInfo)
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

	a.horizonLedgerGauge.Update(int64(a.latestLedgerState.HorizonSequence))
	a.stellarCoreLedgerGauge.Update(int64(a.latestLedgerState.StellarCoreSequence))

	a.horizonConnGauge.Update(int64(a.historyDb.Stats().OpenConnections))
	a.stellarCoreConnGauge.Update(int64(a.coreDb.Stats().OpenConnections))
}
