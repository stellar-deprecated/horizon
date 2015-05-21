package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/sse"
)

// TransactionResource is the display form of a transaction.
type TransactionResource struct {
	halgo.Links
	ID               string `json:"id"`
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

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r TransactionResource) SseEvent() sse.Event {
	return sse.Event{
		Data: r,
		ID:   r.PagingToken,
	}
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
			Link("precedes", "/transactions?cursor=%s&order=asc", tx.PagingToken()).
			Link("succeeds", "/transactions?cursor=%s&order=desc", tx.PagingToken()),
		ID:               tx.TransactionHash,
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
