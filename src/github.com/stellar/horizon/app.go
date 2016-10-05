package horizon

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"runtime"
	"sync"
	"time"

	"github.com/garyburd/redigo/redis"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go/build"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/friendbot"
	"github.com/stellar/horizon/ingest"
	"github.com/stellar/horizon/ledger"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/reap"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/txsub"
	"golang.org/x/net/context"
	"golang.org/x/net/http2"
	"gopkg.in/tylerb/graceful.v1"
)

// You can override this variable using: gb build -ldflags "-X main.version aabbccdd"
var version = ""

// App represents the root of the state of a horizon instance.
type App struct {
	config            Config
	web               *Web
	historyQ          *history.Q
	coreQ             *core.Q
	ctx               context.Context
	cancel            func()
	redis             *redis.Pool
	coreVersion       string
	horizonVersion    string
	networkPassphrase string
	submitter         *txsub.System
	paths             paths.Finder
	friendbot         *friendbot.Bot
	ingester          *ingest.System
	reaper            *reap.System
	ticks             *time.Ticker

	// metrics
	metrics                  metrics.Registry
	historyLatestLedgerGauge metrics.Gauge
	historyElderLedgerGauge  metrics.Gauge
	horizonConnGauge         metrics.Gauge
	coreLatestLedgerGauge    metrics.Gauge
	coreElderLedgerGauge     metrics.Gauge
	coreConnGauge            metrics.Gauge
	goroutineGauge           metrics.Gauge
}

// SetVersion records the provided version string in the package level `version`
// var, which will be used for the reported horizon version.
func SetVersion(v string) {
	version = v
}

// NewApp constructs an new App instance from the provided config.
func NewApp(config Config) (*App, error) {

	result := &App{config: config}
	result.horizonVersion = version
	result.networkPassphrase = build.DefaultNetwork.Passphrase
	result.ticks = time.NewTicker(1 * time.Second)
	result.init()
	return result, nil
}

// Serve starts the horizon web server, binding it to a socket, setting up
// the shutdown signals.
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

	log.Infof("Starting horizon on %s", addr)

	go a.run()

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
	a.ticks.Stop()

	a.historyQ.Repo.DB.Close()
	a.coreQ.Repo.DB.Close()
}

// HistoryQ returns a helper object for performing sql queries against the
// history portion of horizon's database.
func (a *App) HistoryQ() *history.Q {
	return a.historyQ
}

// HorizonRepo returns a new repo that loads data from the horizon database. The
// returned repo is bound to `ctx`.
func (a *App) HorizonRepo(ctx context.Context) *db2.Repo {
	return &db2.Repo{DB: a.historyQ.Repo.DB, Ctx: ctx}
}

// CoreRepo returns a new repo that loads data from the stellar core
// database. The returned repo is bound to `ctx`.
func (a *App) CoreRepo(ctx context.Context) *db2.Repo {
	return &db2.Repo{DB: a.coreQ.Repo.DB, Ctx: ctx}
}

// CoreQ returns a helper object for performing sql queries aginst the
// stellar core database.
func (a *App) CoreQ() *core.Q {
	return a.coreQ
}

// IsHistoryStale returns true if the latest history ledger is more than
// `StaleThreshold` ledgers behind the latest core ledger
func (a *App) IsHistoryStale() bool {
	if a.config.StaleThreshold == 0 {
		return false
	}

	ls := ledger.CurrentState()
	return (ls.CoreLatest - ls.HistoryLatest) > int32(a.config.StaleThreshold)
}

// UpdateLedgerState triggers a refresh of several metrics gauges, such as open
// db connections and ledger state
func (a *App) UpdateLedgerState() {
	var err error
	var next ledger.State

	err = a.CoreQ().LatestLedger(&next.CoreLatest)
	if err != nil {
		goto Failed
	}

	err = a.CoreQ().ElderLedger(&next.CoreElder)
	if err != nil {
		goto Failed
	}

	err = a.HistoryQ().LatestLedger(&next.HistoryLatest)
	if err != nil {
		goto Failed
	}

	err = a.HistoryQ().ElderLedger(&next.HistoryElder)
	if err != nil {
		goto Failed
	}

	ledger.SetState(next)
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
func (a *App) UpdateMetrics() {
	a.goroutineGauge.Update(int64(runtime.NumGoroutine()))
	ls := ledger.CurrentState()
	a.historyLatestLedgerGauge.Update(int64(ls.HistoryLatest))
	a.historyElderLedgerGauge.Update(int64(ls.HistoryElder))
	a.coreLatestLedgerGauge.Update(int64(ls.CoreLatest))
	a.coreElderLedgerGauge.Update(int64(ls.CoreElder))

	a.horizonConnGauge.Update(int64(a.historyQ.Repo.DB.Stats().OpenConnections))
	a.coreConnGauge.Update(int64(a.coreQ.Repo.DB.Stats().OpenConnections))
}

// DeleteUnretainedHistory forwards to the app's reaper.  See
// `reap.DeleteUnretainedHistory` for details
func (a *App) DeleteUnretainedHistory() error {
	return a.reaper.DeleteUnretainedHistory()
}

// Tick triggers horizon to update all of it's background processes such as
// transaction submission, metrics, ingestion and reaping.
func (a *App) Tick() {
	var wg sync.WaitGroup
	log.Debug("ticking app")
	// update ledger state and stellar-core info in parallel
	wg.Add(2)
	go func() { a.UpdateLedgerState(); wg.Done() }()
	go func() { a.UpdateStellarCoreInfo(); wg.Done() }()
	wg.Wait()

	if a.ingester != nil {
		go a.ingester.Tick()
	}

	wg.Add(2)
	go func() { a.reaper.Tick(); wg.Done() }()
	go func() { a.submitter.Tick(a.ctx); wg.Done() }()
	wg.Wait()

	sse.Tick()

	// finally, update metrics
	a.UpdateMetrics()
	log.Debug("finished ticking app")
}

// Init initializes app, using the config to populate db connections and
// whatnot.
func (a *App) init() {
	appInit.Run(a)
}

// run is the function that runs in the background that triggers Tick each
// second
func (a *App) run() {
	for {
		select {
		case <-a.ticks.C:
			a.Tick()
		case <-a.ctx.Done():
			log.Info("finished background ticker")
			return
		}
	}
}
