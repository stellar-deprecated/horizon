package core

import (
	"fmt"
	"math/big"
)

// PagingToken returns a suitable paging token for the Offer
func (r Offer) PagingToken() string {
	return fmt.Sprintf("%d", r.OfferID)
}

// PriceAsString return the price fraction as a floating point approximate.
func (r Offer) PriceAsString() string {
	return big.NewRat(int64(r.Pricen), int64(r.Priced)).FloatString(7)
}
