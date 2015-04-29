package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/zenazn/goji/web"
	"math"
	"net/http"
	"time"
)

type ledgerResource struct {
	halgo.Links
	Id               string    `json:"id"`
	Hash             string    `json:"hash"`
	PrevHash         string    `json:"prev_hash"`
	Sequence         int32     `json:"sequence"`
	TransactionCount int32     `json:"transaction_count"`
	OperationCount   int32     `json:"operation_count"`
	ClosedAt         time.Time `json:"closed_at"`
}

func (l ledgerResource) FromRecord(record db.LedgerRecord) ledgerResource {
	l.Id = record.LedgerHash
	l.Hash = record.LedgerHash
	l.PrevHash = record.PreviousLedgerHash
	l.Sequence = record.Sequence
	return l
}

func ledgerIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c}
	app := ah.App()
	_, order, limit := ah.GetPagingParams()
	after := ah.GetInt32("after")

	if ah.Err() != nil {
		http.Error(w, ah.Err().Error(), http.StatusBadRequest)
		return
	}

	if after == 0 && order == "desc" {
		after = math.MaxInt32
	}

	query := db.LedgerPageQuery{app.HistoryQuery(), after, order, limit}

	render.Collection(w, r, query, ledgerRecordToResource)
}

func ledgerShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c}
	app := ah.App()
	sequence := ah.GetInt32("id")

	if ah.Err() != nil {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	query := db.LedgerBySequenceQuery{app.HistoryQuery(), sequence}

	render.Single(w, r, query, ledgerRecordToResource)
}

func ledgerRecordToResource(record interface{}) (interface{}, error) {
	return ledgerResource{}.FromRecord(record.(db.LedgerRecord)), nil
}
