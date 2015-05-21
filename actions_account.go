package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func accountIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	query := db.HistoryAccountPageQuery{
		SqlQuery:  app.HistoryQuery(),
		PageQuery: ah.GetPageQuery(),
	}

	if ah.Err() != nil {
		http.Error(w, ah.Err().Error(), http.StatusBadRequest)
		return
	}

	render.Collection(ah.Context(), w, r, query, func(record db.Record) (render.Resource, error) {
		ha := record.(db.HistoryAccountRecord)

		return HistoryAccountResource{
			ID:          ha.Address,
			PagingToken: ha.PagingToken(),
			Address:     ha.Address,
		}, nil
	})
}

func accountShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	ctx := ah.Context()
	address := ah.GetString("id")
	if ah.Err() != nil {
		problem.Render(ctx, w, problem.NotFound)
		return
	}

	query := db.AccountByAddressQuery{
		Core:    app.CoreQuery(),
		History: app.HistoryQuery(),
		Address: address,
	}

	render.Single(ctx, w, r, query, accountRecordToResource)
}

func accountRecordToResource(record db.Record) (render.Resource, error) {
	return NewAccountResource(record.(db.AccountRecord)), nil
}
