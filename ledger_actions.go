package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/zenazn/goji/web"
	"net/http"
	"time"
)

type ledgerResource struct {
	halgo.Links
	Id               int       `json:"id"`
	Hash             string    `json:"hash"`
	PrevHash         string    `json:"prev_hash"`
	Sequence         int       `json:"sequence"`
	TransactionCount int       `json:"transaction_count"`
	OperationCount   int       `json:"operation_count"`
	ClosedAt         time.Time `json:"closed_at"`
}

func ledgerIndexAction(w http.ResponseWriter, r *http.Request) {
	renderHAL(w, ledgerResource{})
}

func ledgerShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	renderHAL(w, ledgerResource{})
}
