package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
)

func initHistoryDb(app *App) {
	historyDb, err := db.Open(app.config.DatabaseUrl)

	if err != nil {
		log.Panic(app.ctx, err)
	}
	historyDb.SetMaxIdleConns(4)
	historyDb.SetMaxOpenConns(12)
	app.historyDb = historyDb
}

func initCoreDb(app *App) {
	coreDb, err := db.Open(app.config.StellarCoreDatabaseUrl)

	if err != nil {
		log.Panic(app.ctx, err)
	}

	coreDb.SetMaxIdleConns(4)
	coreDb.SetMaxOpenConns(12)
	app.coreDb = coreDb
}

func init() {
	appInit.Add("history-db", initHistoryDb, "app-context", "log")
	appInit.Add("core-db", initCoreDb, "app-context", "log")
}
