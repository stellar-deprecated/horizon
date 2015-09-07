package horizon

import (
	"github.com/stellar/horizon/db"
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

func init() {
	appInit.Add("history-db", initHistoryDb, "app-context", "log")
	appInit.Add("core-db", initCoreDb, "app-context", "log")
}
