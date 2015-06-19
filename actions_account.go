package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/render/sse"
	"github.com/zenazn/goji/web"
)

func accountIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	ctx := ah.Context()

	query := db.HistoryAccountPageQuery{
		SqlQuery:  app.HistoryQuery(),
		PageQuery: ah.GetPageQuery(),
	}

	if ah.Err() != nil {
		problem.Render(ctx, w, ah.Err())
		return
	}

	var records []db.HistoryAccountRecord

	render := render.Renderer{}
	render.JSON = func() {
		// load records
		err := db.Select(ctx, query, &records)
		if err != nil {
			problem.Render(ctx, w, err)
		}

		page, err := NewHistoryAccountResourcePage(records, query.PageQuery)
		if err != nil {
			problem.Render(ctx, w, err)
		}

		hal.RenderPage(w, page)
	}

	render.SSE = func(stream sse.Stream) {
		err := db.Select(ctx, query, &records)
		if err != nil {
			stream.Err(err)
			return
		}

		records = records[stream.SentCount():]

		for _, record := range records {
			stream.Send(sse.Event{
				ID:   record.PagingToken(),
				Data: NewHistoryAccountResource(record),
			})
		}

		if stream.SentCount() >= int(query.Limit) {
			stream.Done()
		}
	}

	render.Render(ctx, w, r)

}

func accountShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	ctx := ah.Context()

	if ah.Err() != nil {
		problem.Render(ctx, w, problem.NotFound)
		return
	}

	query := db.AccountByAddressQuery{
		Core:    app.CoreQuery(),
		History: app.HistoryQuery(),
		Address: ah.GetString("id"),
	}

	// find account
	found, err := db.First(ah.Context(), query)
	if err != nil {
		problem.Render(ah.Context(), w, ah.Err())
		return
	}

	account, ok := found.(db.AccountRecord)
	if !ok {
		problem.Render(ah.Context(), w, problem.NotFound)
		return
	}

	render := render.Renderer{}
	render.JSON = func() {
		hal.Render(w, NewAccountResource(account))
	}

	render.Render(ctx, w, r)
}
