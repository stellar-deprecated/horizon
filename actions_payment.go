package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func paymentsIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.OperationPageQuery{
		SqlQuery:        app.HistoryQuery(),
		PageQuery:       ah.GetPageQuery(),
		AccountAddress:  ah.GetString("account_id"),
		LedgerSequence:  ah.GetInt32("ledger_id"),
		TransactionHash: ah.GetString("tx_id"),
		TypeFilter:      db.PaymentTypeFilter,
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, problem.ServerError)
		return
	}

	render.Collection(ah.Context(), w, r, q, operationRecordToResource)
}
