package horizon

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/jagregory/halgo"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

// TransactionResource is the display form of a transaction.
type TransactionResource struct {
	halgo.Links
	ID              string    `json:"id"`
	PagingToken     string    `json:"paging_token"`
	Hash            string    `json:"hash"`
	Ledger          int32     `json:"ledger"`
	LedgerCloseTime time.Time `json:"created_at"`
	Account         string    `json:"source_account"`
	AccountSequence int64     `json:"source_account_sequence"`
	MaxFee          int32     `json:"max_fee"`
	FeePaid         int32     `json:"fee_paid"`
	OperationCount  int32     `json:"operation_count"`
	EnvelopeXdr     string    `json:"envelope_xdr"`
	ResultXdr       string    `json:"result_xdr"`
	ResultMetaXdr   string    `json:"result_meta_xdr"`
	MemoType        string    `json:"memo_type"`
	Memo            string    `json:"memo,omitempty"`
	Signatures      []string  `json:"signatures"`
	ValidAfter      string    `json:"valid_after,omitempty"`
	ValidBefore     string    `json:"valid_before,omitempty"`
}

// NewTransactionResource returns a new resource from a TransactionRecord
func NewTransactionResource(tx db.TransactionRecord) TransactionResource {
	self := fmt.Sprintf("/transactions/%s", tx.TransactionHash)
	timeString := func(in sql.NullInt64) string {
		if !in.Valid {
			return ""
		}

		return time.Unix(in.Int64, 0).UTC().Format(time.RFC3339)
	}

	return TransactionResource{
		Links: halgo.Links{}.
			Self(self).
			Link("account", "/accounts/%s", tx.Account).
			Link("ledger", "/ledgers/%d", tx.LedgerSequence).
			Link("operations", "%s/operations%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects%s", self, hal.StandardPagingOptions).
			Link("precedes", "/transactions?cursor=%s&order=asc", tx.PagingToken()).
			Link("succeeds", "/transactions?cursor=%s&order=desc", tx.PagingToken()),
		ID:              tx.TransactionHash,
		PagingToken:     tx.PagingToken(),
		Hash:            tx.TransactionHash,
		Ledger:          tx.LedgerSequence,
		LedgerCloseTime: tx.LedgerCloseTime,
		Account:         tx.Account,
		AccountSequence: tx.AccountSequence,
		MaxFee:          tx.MaxFee,
		FeePaid:         tx.FeePaid,
		OperationCount:  tx.OperationCount,
		EnvelopeXdr:     tx.TxEnvelope,
		ResultXdr:       tx.TxResult,
		ResultMetaXdr:   tx.TxMeta,
		MemoType:        tx.MemoType,
		Memo:            tx.Memo.String,
		Signatures:      strings.Split(tx.SignatureString, ","),
		ValidBefore:     timeString(tx.ValidBefore),
		ValidAfter:      timeString(tx.ValidAfter),
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
