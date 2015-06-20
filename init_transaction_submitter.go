package horizon

import (
	"fmt"
	"net/url"

	"github.com/rcrowley/go-metrics"
)

func initTransactionSubmitter(app *App) {

	u, err := url.Parse(app.config.StellarCoreUrl)

	if err != nil {
		panic(fmt.Sprintf("Could not parse StellarCoreUrl: %s", app.config.StellarCoreUrl))
	}

	app.submitter = &TransactionSubmitter{
		baseURL:         *u,
		submissionTimer: metrics.NewTimer(),
	}
}

func init() {
	appInit.Add("transaction-submitter", initTransactionSubmitter, "log")
}
