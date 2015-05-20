package db

import (
	"fmt"

	sq "github.com/lann/squirrel"
)

// CoreOfferRecordSelect is a sql fragment to help select form queries that
// select into a CoreOfferRecord
var CoreOfferRecordSelect = sq.Select(
	"co.accountid",
	"co.offerid",
	"co.paysalphanumcurrency",
	"co.paysissuer",
	"co.getsalphanumcurrency",
	"co.getsissuer",
	"co.amount",
	"co.pricen",
	"co.priced",
	"co.price",
).From("offers co")

// CoreOfferRecord is row of data from the `offers` table from stellar-core
type CoreOfferRecord struct {
	Accountid            string
	Offerid              int64
	Paysalphanumcurrency string
	Paysissuer           string
	Getsalphanumcurrency string
	Getsissuer           string
	Amount               int64
	Pricen               int32
	Priced               int32
	Price                int64
}

func (r CoreOfferRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Offerid)
}

func (r CoreOfferRecord) PriceAsFloat() float64 {
	return float64(r.Pricen) / float64(r.Priced)
}
