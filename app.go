package horizon

import (
	"fmt"
	"github.com/jinzhu/gorm"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/db"
	"github.com/zenazn/goji/bind"
	"github.com/zenazn/goji/graceful"
	"log"
	"net/http"
)

type App struct {
	config    Config
	metrics   metrics.Registry
	web       *Web
	historyDb gorm.DB
	coreDb    gorm.DB
}

func NewApp(config Config) (*App, error) {
	result := App{
		config:  config,
		metrics: metrics.NewRegistry(),
	}

	web, err := NewWeb(&result)

	if err != nil {
		return nil, err
	}

	historyDb, err := db.Open(config.DatabaseUrl)

	if err != nil {
		return nil, err
	}

	coreDb, err := db.Open(config.StellarCoreDatabaseUrl)

	if err != nil {
		return nil, err
	}

	result.web = web
	result.historyDb = historyDb
	result.coreDb = coreDb
	return &result, nil
}

func (a *App) Serve() {
	a.web.router.Compile()
	http.Handle("/", a.web.router)

	listenStr := fmt.Sprintf(":%d", a.config.Port)
	listener := bind.Socket(listenStr)
	log.Println("Starting horizon on", listener.Addr())

	graceful.HandleSignals()
	bind.Ready()
	graceful.PreHook(func() { log.Printf("received signal, gracefully stopping") })
	graceful.PostHook(func() { log.Printf("stopped") })

	err := graceful.Serve(listener, http.DefaultServeMux)

	if err != nil {
		log.Fatal(err)
	}

	graceful.Wait()
}

// Returns a GormQuery that can be embedded in a parent query
// to specify the query should run against the history database
func (a *App) HistoryQuery() db.GormQuery {
	return db.GormQuery{&a.historyDb}
}

// Returns a GormQuery that can be embedded in a parent query
// to specify the query should run against the connected stellar core database
func (a *App) CoreQuery() db.GormQuery {
	return db.GormQuery{&a.coreDb}
}
