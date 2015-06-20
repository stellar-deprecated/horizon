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

func ledgerIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	ctx := ah.Context()

	// construct query
	ah.ValidateInt64(ParamCursor)
	query := db.LedgerPageQuery{
		SqlQuery:  ah.App().HistoryQuery(),
		PageQuery: ah.GetPageQuery(),
	}

	if ah.Err() != nil {
		problem.Render(ctx, w, ah.Err())
		return
	}

	var records []db.LedgerRecord

	render := render.Renderer{}
	render.JSON = func() {
		// load records
		err := db.Select(ctx, query, &records)
		if err != nil {
			problem.Render(ctx, w, err)
		}

		page, err := NewLedgerResourcePage(records, query.PageQuery)
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
				Data: NewLedgerResource(record),
			})
		}

		if stream.SentCount() >= int(query.Limit) {
			stream.Done()
		}
	}

	render.Render(ctx, w, r)
}

type LedgerShowAction struct {
	Action
	Record db.LedgerRecord
}

func (action LedgerShowAction) ServeHTTPC(c web.C, w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(c, w, r)
	ap.Execute(&action)
}

func (action *LedgerShowAction) Query() db.LedgerBySequenceQuery {
	return db.LedgerBySequenceQuery{
		SqlQuery: action.App.HistoryQuery(),
		Sequence: action.GetInt32("id"),
	}
}

func (action *LedgerShowAction) JSON() {
	query := action.Query()

	if action.Err != nil {
		return
	}

	action.Err = db.Get(action.Ctx, query, &action.Record)

	if action.Err != nil {
		return
	}

	hal.Render(action.W, NewLedgerResource(action.Record))
}
