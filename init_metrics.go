package horizon

import (
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/db"
)

func initMetrics(app *App) {
	app.metrics = metrics.NewRegistry()
}

func initQueryMetric(app *App) {
	app.metrics.Register("db.active_query_count", db.QueryGauge())
}
