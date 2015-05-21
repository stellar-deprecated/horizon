package horizon

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/sse"
)

// LedgerResource represents the summary of a single ledger
type LedgerResource struct {
	halgo.Links
	ID               string         `json:"id"`
	PagingToken      string         `json:"paging_token"`
	Hash             string         `json:"hash"`
	PrevHash         sql.NullString `json:"prev_hash"`
	Sequence         int32          `json:"sequence"`
	TransactionCount int32          `json:"transaction_count"`
	OperationCount   int32          `json:"operation_count"`
	ClosedAt         time.Time      `json:"closed_at"`
}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (l LedgerResource) SseEvent() sse.Event {
	return sse.Event{
		Data: l,
		ID:   l.PagingToken,
	}
}

// NewLedgerResource creates a new resource from a db.LedgerRecord
func NewLedgerResource(in db.LedgerRecord) LedgerResource {
	self := fmt.Sprintf("/ledgers/%d", in.Sequence)
	return LedgerResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", self+"/transactions{?cursor}{?limit}{?order}").
			Link("operations", self+"/operations{?cursor}{?limit}{?order}").
			Link("effects", self+"/effects{?cursor}{?limit}{?order}"),
		ID:          in.LedgerHash,
		PagingToken: in.PagingToken(),
		Hash:        in.LedgerHash,
		PrevHash:    in.PreviousLedgerHash,
		Sequence:    in.Sequence,
	}
}
