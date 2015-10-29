package horizon

import (
	"github.com/getsentry/raven-go"
	"github.com/stellar/horizon/log"
)

// initLog initialized the logging subsystem, attaching app.log and
// app.logMetrics.  It also configured the logger's level using Config.LogLevel.
func initLog(app *App) {
	l, m := log.New()
	l.Logger.Level = app.config.LogLevel
	app.log = l
	app.logMetrics = m
}

// initSentry initialized the default sentry client with the configured DSN
func initSentry(app *App) {
	if app.config.SentryDSN == "" {
		return
	}

	log.Infof(app.ctx, "Initializing sentry hook to: %s", app.config.SentryDSN)
	err := raven.SetDSN(app.config.SentryDSN)
	if err != nil {
		panic(err)
	}
}

// initLogglyLog attaches a loggly hook to our logging system.
func initLogglyLog(app *App) {

	if app.config.LogglyToken == "" {
		return
	}

	log.Infof(app.ctx, "Initializing loggly hook to: %s host: %s", app.config.LogglyToken, app.config.LogglyHost)

	hook := log.NewLogglyHook(app.config.LogglyToken)
	app.log.Logger.Hooks.Add(hook)

	go func() {
		<-app.ctx.Done()
		hook.Flush()
	}()
}

func init() {
	appInit.Add("log", initLog)
	appInit.Add("sentry", initSentry, "log", "app-context")
	appInit.Add("loggly", initLogglyLog, "log", "app-context")
}
