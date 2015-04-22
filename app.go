package horizon

import (
	"github.com/rcrowley/go-metrics"
	"github.com/zenazn/goji/web"
)

type App struct {
	config  Config
	metrics metrics.Registry
	web     *Web
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

	result.web = web
	return &result, nil
}

func (app *App) Router() *web.Mux {
	return app.web.router
}
