package horizon

import (
	"fmt"
	"time"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
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
	TotalCoins       string    `json:"total_coins"`
	FeePool          string    `json:"fee_pool"`
	BaseFee          int32     `json:"base_fee"`
	BaseReserve      string    `json:"base_reserve"`
	MaxTxSetSize     int32     `json:"max_tx_set_size"`
}

// NewLedgerResource creates a new resource from a db.LedgerRecord
func NewLedgerResource(in db.LedgerRecord) LedgerResource {
	self := fmt.Sprintf("/ledgers/%d", in.Sequence)
	return LedgerResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "%s/transactions%s", self, hal.StandardPagingOptions).
			Link("operations", "%s/operations%s", self, hal.StandardPagingOptions).
			Link("effects", "%s/effects%s", self, hal.StandardPagingOptions),
		ID:               in.LedgerHash,
		PagingToken:      in.PagingToken(),
		Hash:             in.LedgerHash,
		PrevHash:         in.PreviousLedgerHash.String,
		Sequence:         in.Sequence,
		TransactionCount: in.TransactionCount,
		OperationCount:   in.OperationCount,
		ClosedAt:         in.ClosedAt,
		TotalCoins:       amount.String(xdr.Int64(in.TotalCoins)),
		FeePool:          amount.String(xdr.Int64(in.FeePool)),
		BaseFee:          in.BaseFee,
		BaseReserve:      amount.String(xdr.Int64(in.BaseReserve)),
		MaxTxSetSize:     in.MaxTxSetSize,
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
