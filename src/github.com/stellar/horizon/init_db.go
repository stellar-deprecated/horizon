package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
)

func initHorizonDb(app *App) {
	horizonDb, err := db.Open(app.config.DatabaseUrl)

	if err != nil {
		log.Panic(err)
	}
	horizonDb.SetMaxIdleConns(4)
	horizonDb.SetMaxOpenConns(12)
	app.horizonDb = horizonDb
}

func initCoreDb(app *App) {
	coreDb, err := db.Open(app.config.StellarCoreDatabaseUrl)

	if err != nil {
		log.Panic(err)
	}

	coreDb.SetMaxIdleConns(4)
	coreDb.SetMaxOpenConns(12)
	app.coreDb = coreDb
}

func init() {
	appInit.Add("horizon-db", initHorizonDb, "app-context", "log")
	appInit.Add("core-db", initCoreDb, "app-context", "log")
}
