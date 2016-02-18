package horizon

import (
	"log"

	"github.com/stellar/horizon/ingest"
)

func initIngester(app *App) {
	if !app.config.Ingest {
		return
	}

	app.ingester = &ingest.Ingester{
		HorizonDB: app.HorizonQuery(),
		CoreDB:    app.CoreQuery(),
	}

	if err := app.ingester.Init(); err != nil {
		log.Panic(err)
	}
}

func init() {
	appInit.Add("ingester", initIngester, "app-context", "log", "horizon-db", "core-db")
}
