package horizon

import (
	"github.com/stellar/horizon/ingest"
)

func initIngester(app *App) {
	if !app.config.Ingest {
		return
	}

	app.ingester = ingest.New(app.CoreQuery(), app.HorizonQuery())
	app.ingester.Start()
}

func init() {
	appInit.Add("ingester", initIngester, "app-context", "log", "horizon-db", "core-db")
}
