package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/txsub"
	"net/http"
)

func initSubmissionSystem(app *App) {
	app.submitter = &txsub.System{
		Pending:   txsub.NewDefaultSubmissionList(),
		Submitter: txsub.NewDefaultSubmitter(http.DefaultClient, app.config.StellarCoreUrl),
		Results: &db.ResultProvider{
			Ctx:     app.ctx,
			Core:    app.coreDb,
			History: app.historyDb,
		},
		NetworkPassphrase: app.networkPassphrase,
	}
}

func init() {
	appInit.Add("txsub", initSubmissionSystem, "app-context", "log", "history-db", "core-db")
}
