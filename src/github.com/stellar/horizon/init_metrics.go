package horizon

import (
	"fmt"

	"github.com/rcrowley/go-metrics"
)

func initMetrics(app *App) {
	app.metrics = metrics.NewRegistry()
}

func initDbMetrics(app *App) {
	app.horizonLedgerGauge = metrics.NewGauge()
	app.stellarCoreLedgerGauge = metrics.NewGauge()
	app.horizonConnGauge = metrics.NewGauge()
	app.stellarCoreConnGauge = metrics.NewGauge()
	app.metrics.Register("history.latest_ledger", app.horizonLedgerGauge)
	app.metrics.Register("stellar_core.latest_ledger", app.stellarCoreLedgerGauge)
	app.metrics.Register("history.open_connections", app.horizonConnGauge)
	app.metrics.Register("stellar_core.open_connections", app.stellarCoreConnGauge)
}

func initLogMetrics(app *App) {
	for level, meter := range *app.logMetrics {
		key := fmt.Sprintf("logging.%s", level)
		app.metrics.Register(key, meter)
	}
}

func initTxSubMetrics(app *App) {
	app.submitter.Init(app.ctx)
	app.metrics.Register("txsub.pending", app.submitter.Metrics.OpenSubmissionsGauge)
	app.metrics.Register("txsub.succeeded", app.submitter.Metrics.SuccessfulSubmissionsMeter)
	app.metrics.Register("txsub.failed", app.submitter.Metrics.FailedSubmissionsMeter)
	app.metrics.Register("txsub.total", app.submitter.Metrics.SubmissionTimer)
}

// initWebMetrics registers the metrics for the web server into the provided
// app's metrics registry.
func initWebMetrics(app *App) {
	app.metrics.Register("requests.total", app.web.requestTimer)
	app.metrics.Register("requests.succeeded", app.web.successMeter)
	app.metrics.Register("requests.failed", app.web.failureMeter)
}

func init() {
	appInit.Add("metrics", initMetrics)
	appInit.Add("log.metrics", initLogMetrics, "metrics")
	appInit.Add("db-metrics", initDbMetrics, "metrics", "history-db", "core-db")
	appInit.Add("web.metrics", initWebMetrics, "web.init", "metrics")
	appInit.Add("txsub.metrics", initTxSubMetrics, "txsub", "metrics")
}
