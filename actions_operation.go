package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func operationIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.OperationPageQuery{
		SqlQuery:        app.HistoryQuery(),
		PageQuery:       ah.GetPageQuery(),
		AccountAddress:  ah.GetString("account_id"),
		LedgerSequence:  ah.GetInt32("ledger_id"),
		TransactionHash: ah.GetString("tx_id"),
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, ah.Err())
		return
	}

	render.Collection(ah.Context(), w, r, q, operationRecordToResource)
}

func operationShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.OperationByIdQuery{
		SqlQuery: app.HistoryQuery(),
		Id:       ah.GetInt64("id"),
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, ah.Err())
		return
	}

	render.Single(ah.Context(), w, r, q, operationRecordToResource)
}
