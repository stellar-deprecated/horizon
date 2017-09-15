package horizon

import (
	"fmt"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/pkg/log"
)

func initMetrics(app *App) {
	app.metrics = metrics.NewRegistry()
}

func initDbMetrics(app *App) {
	app.historyLatestLedgerGauge = metrics.NewGauge()
	app.historyElderLedgerGauge = metrics.NewGauge()
	app.coreLatestLedgerGauge = metrics.NewGauge()
	app.coreElderLedgerGauge = metrics.NewGauge()

	app.horizonConnGauge = metrics.NewGauge()
	app.coreConnGauge = metrics.NewGauge()
	app.goroutineGauge = metrics.NewGauge()
	app.metrics.Register("history.latest_ledger", app.historyLatestLedgerGauge)
	app.metrics.Register("history.elder_ledger", app.historyElderLedgerGauge)
	app.metrics.Register("stellar_core.latest_ledger", app.coreLatestLedgerGauge)
	app.metrics.Register("stellar_core.elder_ledger", app.coreElderLedgerGauge)
	app.metrics.Register("history.open_connections", app.horizonConnGauge)
	app.metrics.Register("stellar_core.open_connections", app.coreConnGauge)
	app.metrics.Register("goroutines", app.goroutineGauge)
}

func initIngesterMetrics(app *App) {
	if app.ingester == nil {
		return
	}
	app.metrics.Register("ingester.ingest_ledger",
		app.ingester.Metrics.IngestLedgerTimer)
	app.metrics.Register("ingester.clear_ledger",
		app.ingester.Metrics.ClearLedgerTimer)
}

func initLogMetrics(app *App) {
	for level, meter := range *log.DefaultMetrics {
		key := fmt.Sprintf("logging.%s", level)
		app.metrics.Register(key, meter)
	}
}

func initTxSubMetrics(app *App) {
	app.submitter.Init()
	app.metrics.Register("txsub.buffered", app.submitter.Metrics.BufferedSubmissionsGauge)
	app.metrics.Register("txsub.open", app.submitter.Metrics.OpenSubmissionsGauge)
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
	appInit.Add("db-metrics", initDbMetrics, "metrics", "horizon-db", "core-db")
	appInit.Add("web.metrics", initWebMetrics, "web.init", "metrics")
	appInit.Add("txsub.metrics", initTxSubMetrics, "txsub", "metrics")
	appInit.Add("ingester.metrics", initIngesterMetrics, "ingester", "metrics")
}
