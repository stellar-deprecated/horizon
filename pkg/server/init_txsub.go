package server

import (
	"net/http"

	"github.com/stellar/horizon/pkg/db2/core"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/txsub"
	results "github.com/stellar/horizon/pkg/txsub/results/db"
	"github.com/stellar/horizon/pkg/txsub/sequence"
)

func initSubmissionSystem(app *App) {
	cq := &core.Q{Session: app.CoreSession(nil)}

	app.submitter = &txsub.System{
		Pending:         txsub.NewDefaultSubmissionList(),
		Submitter:       txsub.NewDefaultSubmitter(http.DefaultClient, app.config.StellarCoreURL),
		SubmissionQueue: sequence.NewManager(),
		Results: &results.DB{
			Core:    cq,
			History: &history.Q{Session: app.HorizonSession(nil)},
		},
		Sequences:         cq.SequenceProvider(),
		NetworkPassphrase: app.networkPassphrase,
	}
}

func init() {
	appInit.Add("txsub", initSubmissionSystem, "app-context", "log", "horizon-db", "core-db")
}
