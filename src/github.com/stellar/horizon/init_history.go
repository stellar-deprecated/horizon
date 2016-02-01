package horizon

import (
	"log"

	"github.com/stellar/horizon/history"
)

func initHistory(app *App) {
	if !app.config.ImportHistory {
		return
	}

	app.importer = &history.Importer{
		HistoryDB: app.HistoryQuery(),
		CoreDB:    app.CoreQuery(),
	}

	if err := app.importer.Init(); err != nil {
		log.Panic(err)
	}
}

func init() {
	appInit.Add("importer", initHistory, "app-context", "log", "history-db", "core-db")
}
