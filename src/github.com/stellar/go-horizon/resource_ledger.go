package horizon

import (
	"fmt"
	"time"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
)

// LedgerResource represents the summary of a single ledger
type LedgerResource struct {
	halgo.Links
	ID               string    `json:"id"`
	PagingToken      string    `json:"paging_token"`
	Hash             string    `json:"hash"`
	PrevHash         string    `json:"prev_hash,omitempty"`
	Sequence         int32     `json:"sequence"`
	TransactionCount int32     `json:"transaction_count"`
	OperationCount   int32     `json:"operation_count"`
	ClosedAt         time.Time `json:"closed_at"`
}

// NewLedgerResource creates a new resource from a db.LedgerRecord
func NewLedgerResource(in db.LedgerRecord) LedgerResource {
	self := fmt.Sprintf("/ledgers/%d", in.Sequence)
	return LedgerResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions/%s", self, hal.StandardPagingOptions).
			Link("operations", "%s/operations/%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions),
		ID:               in.LedgerHash,
		PagingToken:      in.PagingToken(),
		Hash:             in.LedgerHash,
		PrevHash:         in.PreviousLedgerHash.String,
		Sequence:         in.Sequence,
		TransactionCount: in.TransactionCount,
		OperationCount:   in.OperationCount,
		ClosedAt:         in.ClosedAt,
	}
}

func NewLedgerResourcePage(records []db.LedgerRecord, query db.PageQuery) (hal.Page, error) {
	fmts := "/ledgers?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		resources[i] = NewLedgerResource(record)
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
