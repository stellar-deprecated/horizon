package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

func offerIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.CoreOfferPageByAddressQuery{
		SqlQuery:  app.CoreQuery(),
		PageQuery: ah.GetPageQuery(),
		Address:   ah.GetString("account_id"),
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, problem.ServerError)
		return
	}

	render.Collection(ah.Context(), w, r, q, offerRecordToResource)
}
