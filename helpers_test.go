package horizon

import (
	"github.com/PuerkitoBio/throttled"
	"github.com/stellar/go-horizon/test"
	"log"
)

func NewTestApp() *App {
	app, err := NewApp(NewTestConfig())

	if err != nil {
		log.Panic(err)
	}

	return app
}

func NewTestConfig() Config {
	return Config{
		DatabaseUrl:            test.DatabaseUrl(),
		StellarCoreDatabaseUrl: test.StellarCoreDatabaseUrl(),
		RateLimit:              throttled.PerHour(10),
	}
}

func NewRequestHelper(app *App) test.RequestHelper {
	return test.NewRequestHelper(app.web.router)
}
