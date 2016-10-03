package core

import (
	"github.com/stellar/go/amount"
	"github.com/stellar/go/xdr"
	"math/big"
)

// InvertPricef returns the inverted price of the price-level, i.e. what the price would be if you were
// viewing the price level from the other side of the bid/ask dichotomy.
func (p *PriceLevel) InvertPricef() float64 {
	return float64(p.Priced) / float64(p.Pricen)
}

// PriceAsString returns the price as a string
func (p *PriceLevel) PriceAsString() string {
	return big.NewRat(int64(p.Pricen), int64(p.Priced)).FloatString(7)
}

// AmountAsString returns the amount as a string, formatted using
// the amount.String() utility from go.
func (p *PriceLevel) AmountAsString() string {
	return amount.String(xdr.Int64(p.Amount))
}
