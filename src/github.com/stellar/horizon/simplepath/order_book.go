package simplepath

import (
	"github.com/stellar/go-stellar-base/xdr"
)

type OrderBook struct {
	Selling xdr.Asset
	Buying  xdr.Asset
}

func (ob *OrderBook) Cost(source xdr.Asset, amount xdr.Int64) xdr.Int64 {
	return amount
}
