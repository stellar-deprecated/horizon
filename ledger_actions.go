package horizon

import (
	"./hal"
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/zenazn/goji/web"
	"net/http"
	"strconv"
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

func ledgerIndexAction(w http.ResponseWriter, r *http.Request) {
	hal.Render(w, ledgerResource{})
}

func ledgerShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	sequenceStr := c.URLParams["id"]
	sequence64, err := strconv.ParseInt(sequenceStr, 10, 32)

	if err != nil {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}

	sequence := int32(sequence64)
	app := c.Env["app"].(*App)
	query := db.LedgerBySequenceQuery{sequence}

	records, err := query.Run(app.historyDb)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if len(records) == 0 {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}

	record := records[0].(db.LedgerRecord)

	hal.Render(w, ledgerResource{}.FromRecord(record))
}
