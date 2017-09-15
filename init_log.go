package horizon

import (
	"github.com/getsentry/raven-go"
	"github.com/stellar/horizon/log"
)

// initLog initialized the logging subsystem, attaching app.log and
// app.logMetrics.  It also configured the logger's level using Config.LogLevel.
func initLog(app *App) {
	log.DefaultLogger.Logger.Level = app.config.LogLevel
}

// initSentry initialized the default sentry client with the configured DSN
func initSentry(app *App) {
	if app.config.SentryDSN == "" {
		return
	}

	log.WithField("dsn", app.config.SentryDSN).Info("Initializing sentry")
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

	log.WithFields(log.F{
		"token":       app.config.LogglyToken,
		"loggly_host": app.config.LogglyHost,
	}).Info("Initializing loggly hook")

	hook := log.NewLogglyHook(app.config.LogglyToken)
	log.DefaultLogger.Logger.Hooks.Add(hook)

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
