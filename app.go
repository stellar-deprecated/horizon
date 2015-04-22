package horizon

import (
	"github.com/zenazn/goji/web"
)

type App struct {
	config Config
	web    *Web
}

func NewApp(config Config) (*App, error) {
	result := App{config: config}

	web, err := NewWeb()

	if err != nil {
		return nil, err
	}

	result.web = web

	return &result, nil
}

func (app *App) Router() *web.Mux {
	return app.web.router
}
