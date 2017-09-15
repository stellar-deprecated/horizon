package horizon

import (
	"log"

	"github.com/stellar/horizon/pkg/ingest"
)

func initIngester(app *App) {
	if !app.config.Ingest {
		return
	}

	if app.networkPassphrase == "" {
		log.Fatal("Cannot start ingestion without network passphrase.  Please confirm connectivity with stellar-core.")
	}

	app.ingester = ingest.New(
		app.networkPassphrase,
		app.config.StellarCoreURL,
		app.CoreSession(nil),
		app.HorizonSession(nil),
	)

	app.ingester.SkipCursorUpdate = app.config.SkipCursorUpdate
}

func init() {
	appInit.Add("ingester", initIngester, "app-context", "log", "horizon-db", "core-db", "stellarCoreInfo")
}
