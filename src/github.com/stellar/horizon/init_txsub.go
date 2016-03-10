package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/queries/core"
	"github.com/stellar/horizon/db/queries/history"
	"github.com/stellar/horizon/db/rp"
	"github.com/stellar/horizon/txsub"
	"github.com/stellar/horizon/txsub/sequence"
	"net/http"
)

func initSubmissionSystem(app *App) {
	app.submitter = &txsub.System{
		Pending:         txsub.NewDefaultSubmissionList(),
		Submitter:       txsub.NewDefaultSubmitter(http.DefaultClient, app.config.StellarCoreURL),
		SubmissionQueue: sequence.NewManager(),
		Results: &rp.ResultProvider{
			Core:    &core.Q{Repo: app.CoreRepo(nil)},
			History: &history.Q{Repo: app.HorizonRepo(nil)},
		},
		Sequences: db.SequenceByAddressQuery{
			SqlQuery: app.CoreQuery(),
		},
		NetworkPassphrase: app.networkPassphrase,
	}

	go func() {
		ticks := app.pump.Subscribe()

		for _ = range ticks {
			app.submitter.Tick(app.ctx)
		}
	}()

}

func init() {
	appInit.Add("txsub", initSubmissionSystem, "app-context", "log", "horizon-db", "core-db", "pump")
}
