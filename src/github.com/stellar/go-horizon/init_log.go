package horizon

import (
	"time"

	"github.com/Sirupsen/logrus"
	"github.com/Sirupsen/logrus/hooks/sentry"
	_ "github.com/getsentry/raven-go" //raven-go is needed by sentry hook
	"github.com/stellar/go-horizon/log"
)

// initLog initialized the logging subsystem, attaching app.log and
// app.logMetrics.  It also configured the logger's level using Config.LogLevel.
func initLog(app *App) {
	l, m := log.New()
	l.Logger.Level = app.config.LogLevel
	app.log = l
	app.logMetrics = m
}

// initSentryLog attaches a hook to our logging system that will report
// errors and panics to the configured sentry server (from Config.SentryDSN).
func initSentryLog(app *App) {
	if app.config.SentryDSN == "" {
		return
	}

	log.Infof(app.ctx, "Initializing sentry hook to: %s", app.config.SentryDSN)

	hook, err := logrus_sentry.NewSentryHook(app.config.SentryDSN, []logrus.Level{
		logrus.PanicLevel,
		logrus.FatalLevel,
		logrus.ErrorLevel,
	})

	hook.Timeout = 1 * time.Second

	if err != nil {
		panic(err)
	}

	app.log.Logger.Hooks.Add(hook)

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
	appInit.Add("sentry", initSentryLog, "log", "app-context")
	appInit.Add("loggly", initLogglyLog, "log", "app-context")
}
