package db

import (
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"math/big"
)

// PriceLevelRecord represents an aggregation of offers to trade at a certain
// price.
type PriceLevelRecord struct {
	Pricen int32   `db:"pricen"`
	Priced int32   `db:"priced"`
	Pricef float64 `db:"pricef"`
	Amount int64   `db:"amount"`
}

// InvertPricef returns the inverted price of the price-level, i.e. what the price would be if you were
// viewing the price level from the other side of the bid/ask dichotomy.
func (p *PriceLevelRecord) InvertPricef() float64 {
	return float64(p.Priced) / float64(p.Pricen)
}

// PriceAsString returns the price as a string
func (p *PriceLevelRecord) PriceAsString() string {
	return big.NewRat(int64(p.Pricen), int64(p.Priced)).FloatString(7)
}

// AmountAsString returns the amount as a string, formatted using
// the amount.String() utility from go-stellar-base.
func (p *PriceLevelRecord) AmountAsString() string {
	return amount.String(xdr.Int64(p.Amount))
}
