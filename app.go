package horizon

import (
	"database/sql"
	"fmt"
	"github.com/garyburd/redigo/redis"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/db"
	"github.com/zenazn/goji/bind"
	"github.com/zenazn/goji/graceful"
	"golang.org/x/net/context"
	"log"
	"net/http"
)

type App struct {
	config    Config
	metrics   metrics.Registry
	web       *Web
	historyDb *sql.DB
	coreDb    *sql.DB
	ctx       context.Context
	cancel    func()
	redis     *redis.Pool
}

func initAppCancel(app *App) {
	ctx, cancel := context.WithCancel(context.Background())
	app.ctx = ctx
	app.cancel = cancel
}

func NewApp(config Config) (*App, error) {

	init := &AppInit{}
	init.Add(Initializer{
		"cancel",
		initAppCancel,
		nil,
	})
	init.Add(Initializer{
		"metrics",
		initMetrics,
		nil,
	})
	init.Add(Initializer{
		"redis",
		initRedis,
		nil,
	})
	init.Add(Initializer{
		"history-db",
		initHistoryDb,
		nil,
	})
	init.Add(Initializer{
		"core-db",
		initCoreDb,
		nil,
	})
	init.Add(Initializer{
		"db-metrics",
		initDbMetrics,
		[]string{
			"metrics",
			"history-db",
			"core-db",
		},
	})
	init.Add(Initializer{
		"web.init",
		initWeb,
		nil,
	})
	init.Add(Initializer{
		"web.metrics",
		initWebMetrics,
		[]string{
			"web.init",
			"metrics",
		},
	})
	init.Add(Initializer{
		"web.rate-limiter",
		initWebRateLimiter,
		[]string{
			"web.init",
		},
	})
	init.Add(Initializer{
		"web.middleware",
		initWebMiddleware,
		[]string{
			"web.init",
			"web.rate-limiter",
			"web.metrics",
		},
	})
	init.Add(Initializer{
		"web.actions",
		initWebActions,
		[]string{
			"web.init",
		},
	})

	result := &App{config: config}
	init.Run(result)

	return result, nil
}

func (a *App) Serve() {

	a.web.router.Compile()
	http.Handle("/", a.web.router)

	listenStr := fmt.Sprintf(":%d", a.config.Port)
	listener := bind.Socket(listenStr)
	log.Println("Starting horizon on", listener.Addr())

	graceful.HandleSignals()
	bind.Ready()
	graceful.PreHook(func() {
		log.Printf("received signal, gracefully stopping")
		a.Cancel()
	})
	graceful.PostHook(func() {
		log.Printf("stopped")
	})

	if a.config.Autopump {
		db.AutoPump(a.ctx)
	}

	// initiate the ledger close pumper
	db.LedgerClosePump(a.ctx, a.historyDb)

	err := graceful.Serve(listener, http.DefaultServeMux)

	if err != nil {
		log.Fatal(err)
	}

	graceful.Wait()
}

func (a *App) Cancel() {
	a.cancel()
}

func (a *App) Close() {
	a.Cancel()
	a.historyDb.Close()
	a.coreDb.Close()
}

// Returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the history database
func (a *App) HistoryQuery() db.SqlQuery {
	return db.SqlQuery{a.historyDb}
}

// Returns a SqlQuery that can be embedded in a parent query
// to specify the query should run against the connected stellar core database
func (a *App) CoreQuery() db.SqlQuery {
	return db.SqlQuery{a.coreDb}
}
