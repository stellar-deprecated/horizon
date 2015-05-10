package horizon

import (
	"github.com/stellar/go-horizon/db"
	"log"
)

func initHistoryDb(app *App) {
	historyDb, err := db.Open(app.config.DatabaseUrl)

	if err != nil {
		log.Panic(err)
	}
	app.historyDb = historyDb
}

func initCoreDb(app *App) {
	coreDb, err := db.Open(app.config.StellarCoreDatabaseUrl)

	if err != nil {
		log.Panic(err)
	}
	app.coreDb = coreDb
}
