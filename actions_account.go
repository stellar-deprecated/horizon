package horizon

import (
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"net/http"
)

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
