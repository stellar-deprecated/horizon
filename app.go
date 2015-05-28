package horizon

import (
	"database/sql"
	"fmt"
	"net/http"

	"github.com/Sirupsen/logrus"
	"github.com/garyburd/redigo/redis"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/log"
	"github.com/zenazn/goji/bind"
	"github.com/zenazn/goji/graceful"
	"golang.org/x/net/context"
)

var appContextKey = 0

type App struct {
	config     Config
	metrics    metrics.Registry
	web        *Web
	historyDb  *sql.DB
	coreDb     *sql.DB
	ctx        context.Context
	cancel     func()
	redis      *redis.Pool
	log        *logrus.Entry
	logMetrics *log.Metrics
}

// AppFromContext retrieves a *App from the context tree.
func AppFromContext(ctx context.Context) (*App, bool) {
	a, ok := ctx.Value(&appContextKey).(*App)
	return a, ok
}

// NewApp constructs an new App instance from the provided config.
func NewApp(config Config) (*App, error) {

	result := &App{config: config}
	appInit.Run(result)

	return result, nil
}

// Serve starts the go-horizon system, binding it to a socket, setting up
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

	if a.config.Autopump {
		db.AutoPump(a.ctx)
	}

	// initiate the ledger close pumper
	db.LedgerClosePump(a.ctx, a.historyDb)

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
