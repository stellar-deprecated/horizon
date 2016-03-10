package horizon

import (
	"github.com/stellar/horizon/db2"
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

	core := &db2.Repo{DB: app.coreDb}
	horz := &db2.Repo{DB: app.horizonDb}
	app.ingester = ingest.New(app.networkPassphrase, core, horz)
	app.ingester.Start()
}

func init() {
	appInit.Add("ingester", initIngester, "app-context", "log", "horizon-db", "core-db", "stellarCoreInfo")
}
