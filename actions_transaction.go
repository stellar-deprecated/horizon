package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func transactionIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.TransactionPageQuery{
		SqlQuery:       app.HistoryQuery(),
		PageQuery:      ah.GetPageQuery(),
		AccountAddress: ah.GetString("account_id"),
		LedgerSequence: ah.GetInt32("ledger_id"),
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, ah.Err())
		return
	}

	render.Collection(ah.Context(), w, r, q, transactionRecordToResource)
}

func transactionShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	hash := ah.GetString("id")

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, ah.Err())
		return
	}

	q := db.TransactionByHashQuery{
		SqlQuery: app.HistoryQuery(),
		Hash:     hash,
	}

	render.Single(ah.Context(), w, r, q, transactionRecordToResource)
}

func transactionCreateAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	txHex := ah.GetString("tx")
	txHash, err := ah.App().submitter.Submit(ah.Context(), txHex)

	if err != nil {
		problem.Render(ah.Context(), w, err)
		return
	}

	hal.Render(w, NewSubmissionResource(txHash))
}
