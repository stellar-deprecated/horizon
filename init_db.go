package horizon

import (
	"github.com/stellar/go-horizon/db"
)

func initHistoryDb(app *App) {
	historyDb, err := db.Open(app.config.DatabaseUrl)

	if err != nil {
		app.log.Panic(app.ctx, err)
	}
	app.historyDb = historyDb
}

func initCoreDb(app *App) {
	coreDb, err := db.Open(app.config.StellarCoreDatabaseUrl)

	if err != nil {
		app.log.Panic(app.ctx, err)
	}
	app.coreDb = coreDb
}
