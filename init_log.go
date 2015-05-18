package horizon

import "github.com/stellar/go-horizon/log"

func initLog(app *App) {
	l, m := log.New()
	l.Logger.Level = app.config.LogLevel
	app.log = l
	app.logMetrics = m
}
