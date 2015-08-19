package horizon

import (
	_ "database/sql"
	_ "fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	_ "github.com/stellar/go-horizon/render/hal"
	_ "github.com/stellar/go-stellar-base/xdr"
)

// OrderBookSummaryResource is the display form of an OrderBookSummary record.
type OrderBookSummaryResource struct {
	halgo.Links
}

func NewOrderBookSummaryResource(db.OrderBookSummaryRecord) OrderBookSummaryResource {
	return OrderBookSummaryResource{}
}
