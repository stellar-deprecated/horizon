package horizon

import (
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db/queries/history"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/log"
)

func initHorizonDb(app *App) {
	repo, err := db2.Open(app.config.DatabaseURL)

	if err != nil {
		log.Panic(err)
	}
	repo.DB.SetMaxIdleConns(4)
	repo.DB.SetMaxOpenConns(12)

	app.historyQ = &history.Q{repo}
}

func initCoreDb(app *App) {
	repo, err := db2.Open(app.config.StellarCoreDatabaseURL)

	if err != nil {
		log.Panic(err)
	}

	repo.DB.SetMaxIdleConns(4)
	repo.DB.SetMaxOpenConns(12)
	app.coreQ = &core.Q{repo}
}

func init() {
	appInit.Add("horizon-db", initHorizonDb, "app-context", "log")
	appInit.Add("core-db", initCoreDb, "app-context", "log")
}
