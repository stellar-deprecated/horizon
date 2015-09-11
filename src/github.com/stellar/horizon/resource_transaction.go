package horizon

import (
	"fmt"
	"time"

	"github.com/jagregory/halgo"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

// TransactionResource is the display form of a transaction.
type TransactionResource struct {
	halgo.Links
	ID               string    `json:"id"`
	PagingToken      string    `json:"paging_token"`
	Hash             string    `json:"hash"`
	Ledger           int32     `json:"ledger"`
	LedgerCloseTime  time.Time `json:"created_at"`
	Account          string    `json:"account"`
	AccountSequence  int64     `json:"account_sequence"`
	MaxFee           int32     `json:"max_fee"`
	FeePaid          int32     `json:"fee_paid"`
	OperationCount   int32     `json:"operation_count"`
	ResultCode       int32     `json:"result_code"`
	ResultCodeString string    `json:"result_code_s"`
	EnvelopeXdr      string    `json:"envelope_xdr"`
	ResultXdr        string    `json:"result_xdr"`
	ResultMetaXdr    string    `json:"result_meta_xdr"`
}

// NewTransactionResource returns a new resource from a TransactionRecord
func NewTransactionResource(tx db.TransactionRecord) TransactionResource {
	self := fmt.Sprintf("/transactions/%s", tx.TransactionHash)

	return TransactionResource{
		Links: halgo.Links{}.
			Self(self).
			Link("account", "/accounts/%s", tx.Account).
			Link("ledger", "/ledgers/%d", tx.LedgerSequence).
			Link("operations", "%s/operations%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects%s", self, hal.StandardPagingOptions).
			Link("precedes", "/transactions?cursor=%s&order=asc", tx.PagingToken()).
			Link("succeeds", "/transactions?cursor=%s&order=desc", tx.PagingToken()),
		ID:               tx.TransactionHash,
		PagingToken:      tx.PagingToken(),
		Hash:             tx.TransactionHash,
		Ledger:           tx.LedgerSequence,
		LedgerCloseTime:  tx.LedgerCloseTime,
		Account:          tx.Account,
		AccountSequence:  tx.AccountSequence,
		MaxFee:           tx.MaxFee,
		FeePaid:          tx.FeePaid,
		OperationCount:   tx.OperationCount,
		ResultCode:       0, //NOTE: if at some point a history_transaction row records the result code, use it
		ResultCodeString: "tx_success",
		EnvelopeXdr:      tx.TxEnvelope.String,
		ResultXdr:        tx.TxResult.String,
		ResultMetaXdr:    tx.TxMeta.String,
	}
}

// NewTransactionResourcePage initialzed a hal.Page from s a slice of
// OperationRecords
func NewTransactionResourcePage(records []db.TransactionRecord, query db.PageQuery, path string) (hal.Page, error) {
	fmts := path + "?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		resources[i] = NewTransactionResource(record)
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
