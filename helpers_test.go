package horizon

import (
	"github.com/stellar/go-horizon/test"
	"log"
)

func NewTestApp() *App {
	app, err := NewApp(Config{
		DatabaseUrl:            test.DatabaseUrl(),
		StellarCoreDatabaseUrl: test.StellarCoreDatabaseUrl(),
	})

	if err != nil {
		log.Panic(err)
	}

	app.historyDb.LogMode(true)

	return app
}

func NewRequestHelper(app *App) test.RequestHelper {
	return test.NewRequestHelper(app.web.router)
}
