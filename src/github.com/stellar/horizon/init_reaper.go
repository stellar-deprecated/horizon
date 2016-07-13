package horizon

import (
	"github.com/stellar/horizon/reap"
)

func initReaper(app *App) {
	app.reaper = reap.New(app.config.HistoryRetentionCount, app.HorizonRepo(nil))
	app.reaper.Start()
}

func init() {
	appInit.Add("reaper", initReaper, "app-context", "log", "horizon-db")
}
