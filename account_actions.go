package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"net/http"
)

type AccountResource struct {
	halgo.Links
	Id       string `json:"id"`
	Address  string `json:"address"`
	Sequence int64  `json:"sequence"`
}

// sse.Event methods

func (r AccountResource) SseData() interface{} { return r }
func (r AccountResource) Err() error           { return nil }
func (r AccountResource) SseId() string        { return r.Id }

func (r AccountResource) FromRecord(record db.CoreAccountRecord) AccountResource {
	r.Id = record.Accountid
	r.Address = record.Accountid
	r.Sequence = record.Seqnum
	return r
}

func accountShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	address := ah.GetString("id")
	if ah.Err() != nil {
		problem.Render(app.ctx, w, problem.NotFound)
		return
	}

	q := db.CoreAccountByAddressQuery{
		app.CoreQuery(),
		address,
	}

	render.Single(w, r, q, func(r db.Record) (render.Resource, error) {
		return AccountResource{}.FromRecord(r.(db.CoreAccountRecord)), nil
	})
}
