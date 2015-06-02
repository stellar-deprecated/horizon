package horizon

import (
	"fmt"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/db"
)

func initMetrics(app *App) {
	app.metrics = metrics.NewRegistry()
}

func initDbMetrics(app *App) {
	app.metrics.Register("db.active_query_count", db.QueryGauge())
	app.metrics.Register("db.active_query_count", db.QueryGauge())
	app.metrics.Register("history.latest_ledger", db.HorizonLedgerGauge())
	app.metrics.Register("stellar_core.latest_ledger", db.StellarCoreLedgerGauge())
}

func initLogMetrics(app *App) {
	for level, meter := range *app.logMetrics {
		key := fmt.Sprintf("logging.%s", level)
		app.metrics.Register(key, meter)
	}
}

// initWebMetrics registers the metrics for the web server into the provided
// app's metrics registry.
func initWebMetrics(app *App) {
	app.metrics.Register("requests.total", app.web.requestTimer)
	app.metrics.Register("requests.succeeded", app.web.successMeter)
	app.metrics.Register("requests.failed", app.web.failureMeter)
}

func initSubmitterMetrics(app *App) {
	app.metrics.Register("submissions", app.submitter.submissionTimer)
}

func init() {
	appInit.Add("metrics", initMetrics)
	appInit.Add("log.metrics", initLogMetrics, "metrics")
	appInit.Add("db-metrics", initDbMetrics, "metrics", "history-db", "core-db")
	appInit.Add("web.metrics", initWebMetrics, "web.init", "metrics")
	appInit.Add("transaction-submitter.metrics", initSubmitterMetrics, "transaction-submitter", "metrics")
}
