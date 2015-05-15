package horizon

import (
	"fmt"
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"net/http"
)

type OperationResource struct {
	halgo.Links
	Id          int64  `json:"id"`
	PagingToken string `json:"paging_token"`
}

func (r OperationResource) SseData() interface{} { return r }
func (r OperationResource) Err() error           { return nil }
func (r OperationResource) SseId() string        { return r.PagingToken }

func operationIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.OperationPageQuery{
		app.HistoryQuery(),
		ah.GetPageQuery(),
		ah.GetString("account_id"),
		ah.GetInt32("ledger_id"),
		ah.GetString("tx_id"),
	}

	if ah.Err() != nil {
		problem.Render(ah.Context(), w, problem.ServerError)
		return
	}

	render.Collection(ah.Context(), w, r, q, operationRecordToResource)
}

func operationRecordToResource(record db.Record) (render.Resource, error) {
	op := record.(db.OperationRecord)
	self := fmt.Sprintf("/operations/%s", op.Id)
	po := "{?cursor}{?limit}{?order}"

	resource := OperationResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "/transactions/%s", op.TransactionId).
			Link("effects", "%s/effects/%s", self, po).
			Link("precedes", "/operations?cursor=%d&order=asc", op.PagingToken()).
			Link("succeeds", "/operations?cursor=%d&order=desc", op.PagingToken()),
		Id:          op.Id,
		PagingToken: op.PagingToken(),
	}

	return resource, nil
}
