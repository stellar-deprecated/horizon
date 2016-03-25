package horizon

import (
	"github.com/stellar/horizon/ingest"
	"log"
)

func initIngester(app *App) {
	if !app.config.Ingest {
		return
	}

	if app.networkPassphrase == "" {
		log.Fatal("Cannot start ingestion without network passphrase.  Please confirm connectivity with stellar-core.")
	}

	app.ingester = ingest.New(app.networkPassphrase, app.CoreRepo(nil), app.HorizonRepo(nil))
	app.ingester.Start()
}

func init() {
	appInit.Add("ingester", initIngester, "app-context", "log", "horizon-db", "core-db", "stellarCoreInfo")
}
