package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func ledgerIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	query := db.LedgerPageQuery{
		SqlQuery:  app.HistoryQuery(),
		PageQuery: ah.GetPageQuery(),
	}

	if ah.Err() != nil {
		http.Error(w, ah.Err().Error(), http.StatusBadRequest)
		return
	}

	render.Collection(ah.Context(), w, r, query, ledgerRecordToResource)
}

func ledgerShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	sequence := ah.GetInt32("id")

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, problem.NotFound)
		return
	}

	query := db.LedgerBySequenceQuery{
		SqlQuery: app.HistoryQuery(),
		Sequence: sequence,
	}

	render.Single(ah.Context(), w, r, query, ledgerRecordToResource)
}

func ledgerRecordToResource(record db.Record) (render.Resource, error) {
	return NewLedgerResource(record.(db.LedgerRecord)), nil
}
