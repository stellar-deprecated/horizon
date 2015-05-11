package horizon

import (
	"fmt"
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
)

type TransactionResource struct {
	halgo.Links
	Id               string `json:"id"`
	PagingToken      string `json:"paging_token"`
	Hash             string `json:"hash"`
	Ledger           int32  `json:"ledger"`
	Account          string `json:"account"`
	AccountSequence  int64  `json:"account_sequence"`
	MaxFee           int32  `json:"max_fee"`
	FeePaid          int32  `json:"fee_paid"`
	OperationCount   int32  `json:"operation_count"`
	ResultCode       int32  `json:"result_code"`
	ResultCodeString string `json:"result_code_s"`
	EnvelopeXdr      string `json:"envelope_xdr"`
	ResultXdr        string `json:"result_xdr"`
	ResultMetaXdr    string `json:"result_meta_xdr"`
}

func (r TransactionResource) SseData() interface{} { return r }
func (r TransactionResource) Err() error           { return nil }
func (r TransactionResource) SseId() string        { return r.Id }

func NewTransactionResource(in interface{}) TransactionResource {
	return TransactionResource{}
}

func transactionIndexAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()

	q := db.TransactionPageQuery{
		app.HistoryQuery(),
		ah.GetPageQuery(),
		ah.GetString("account_id"),
		ah.GetInt32("ledger_id"),
	}

	if ah.Err() != nil {
		problem.Render(context.TODO(), w, problem.ServerError)
		return
	}

	render.Collection(w, r, q, transactionRecordToResource)
}

func transactionShowAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	app := ah.App()
	hash := ah.GetString("id")

	if ah.Err() != nil {
		problem.Render(context.TODO(), w, problem.NotFound)
		return
	}

	q := db.TransactionByHashQuery{
		app.HistoryQuery(),
		hash,
	}

	render.Single(w, r, q, transactionRecordToResource)
}

func transactionRecordToResource(record db.Record) (render.Resource, error) {
	tx := record.(db.TransactionRecord)
	self := fmt.Sprintf("/transactions/%s", tx.TransactionHash)
	po := "{?cursor}{?limit}{?order}"

	resource := TransactionResource{
		Links: halgo.Links{}.
			Self(self).
			Link("account", "/accounts/%s", tx.Account).
			Link("ledger", "/ledgers/%d", tx.LedgerSequence).
			Link("operations", "%s/operations/%s", self, po).
			Link("effects", "%s/effects/%s", self, po).
			Link("precedes", "/transactions?cursor=%d&order=asc", tx.PagingToken()).
			Link("succeeds", "/transactions?cursor=%d&order=desc", tx.PagingToken()),
		Id:               tx.TransactionHash,
		PagingToken:      tx.PagingToken(),
		Hash:             tx.TransactionHash,
		Ledger:           tx.LedgerSequence,
		Account:          tx.Account,
		AccountSequence:  tx.AccountSequence,
		MaxFee:           tx.MaxFee,
		FeePaid:          tx.FeePaid,
		OperationCount:   tx.OperationCount,
		ResultCode:       0,
		ResultCodeString: "tx_success",
		EnvelopeXdr:      "TODO",
		ResultXdr:        "TODO",
		ResultMetaXdr:    "TODO",
	}

	return resource, nil
}
