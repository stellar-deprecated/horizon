package horizon

import (
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db/queries/history"
	"github.com/stellar/horizon/db/rp"
	"github.com/stellar/horizon/txsub"
	"github.com/stellar/horizon/txsub/sequence"
	"net/http"
)

func initSubmissionSystem(app *App) {
	cq := &core.Q{Repo: app.CoreRepo(nil)}

	app.submitter = &txsub.System{
		Pending:         txsub.NewDefaultSubmissionList(),
		Submitter:       txsub.NewDefaultSubmitter(http.DefaultClient, app.config.StellarCoreURL),
		SubmissionQueue: sequence.NewManager(),
		Results: &rp.ResultProvider{
			Core:    cq,
			History: &history.Q{Repo: app.HorizonRepo(nil)},
		},
		Sequences:         cq.SequenceProvider(),
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
