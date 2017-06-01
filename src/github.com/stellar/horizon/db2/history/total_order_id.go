package history

import (
	"fmt"

	"github.com/stellar/horizon/toid"
)

// GetLedgerSequence implements LedgerSequencer
func (r *TotalOrderID) GetLedgerSequence() int32 {
	id := toid.Parse(r.ID)
	return id.LedgerSequence
}

// PagingToken returns a cursor for this record
func (r *TotalOrderID) PagingToken() string {
	return fmt.Sprintf("%d", r.ID)
}
