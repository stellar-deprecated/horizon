package horizon

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
)

// LedgerResource represents the summary of a single ledger
type LedgerResource struct {
	halgo.Links
	Id               string         `json:"id"`
	PagingToken      string         `json:"paging_token"`
	Hash             string         `json:"hash"`
	PrevHash         sql.NullString `json:"prev_hash"`
	Sequence         int32          `json:"sequence"`
	TransactionCount int32          `json:"transaction_count"`
	OperationCount   int32          `json:"operation_count"`
	ClosedAt         time.Time      `json:"closed_at"`
}

func (l LedgerResource) SseData() interface{} { return l }
func (l LedgerResource) Err() error           { return nil }
func (l LedgerResource) SseId() string        { return l.PagingToken }

// NewLedgerResource creates a new resource from a db.LedgerRecord
func NewLedgerResource(in db.LedgerRecord) LedgerResource {
	self := fmt.Sprintf("/ledgers/%d", in.Sequence)
	return LedgerResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", self+"/transactions{?cursor}{?limit}{?order}").
			Link("operations", self+"/operations{?cursor}{?limit}{?order}").
			Link("effects", self+"/effects{?cursor}{?limit}{?order}"),
		Id:          in.LedgerHash,
		PagingToken: in.PagingToken(),
		Hash:        in.LedgerHash,
		PrevHash:    in.PreviousLedgerHash,
		Sequence:    in.Sequence,
	}
}
