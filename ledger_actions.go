package horizon

import (
	"./hal"
	"fmt"
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/zenazn/goji/web"
	"math"
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

func ledgerIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	afterStr, order, limit, err := extractPagingParams(c)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	switch order {
	case "":
		order = "asc"
	case "asc", "desc":
		break
	default:
		http.Error(w, "Invalid order", http.StatusBadRequest)
		return
	}

	if afterStr == "" {
		switch order {
		case "asc":
			afterStr = "0"
		case "desc":
			afterStr = fmt.Sprint(math.MaxInt32)
		}
	}

	after, err := strconv.ParseInt(afterStr, 10, 32)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	app := c.Env["app"].(*App)
	query := db.LedgerPageQuery{
		db.GormQuery{&app.historyDb},
		int32(after),
		order,
		limit,
	}

	records, err := query.Get()

	resources := make([]interface{}, len(records))
	for i := range records {
		record := records[i].(db.LedgerRecord)
		resource := ledgerResource{}.FromRecord(record)
		resources[i] = resource
	}

	page := hal.Page{
		Records: resources,
	}

	hal.RenderPage(w, page)
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
	query := db.LedgerBySequenceQuery{db.GormQuery{&app.historyDb}, sequence}

	records, err := query.Get()

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

func extractPagingParams(c web.C) (after string, order string, limit int32, err error) {
	after = c.URLParams["after"]
	order = c.URLParams["order"]
	limitStr := c.URLParams["limit"]

	if limitStr == "" {
		limit = 10
	} else {
		var limit64 int64
		limit64, err = strconv.ParseInt(limitStr, 10, 32)

		if err != nil {
			return
		}

		limit = int32(limit64)
	}

	return
}
