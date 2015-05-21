package db

import (
	"database/sql"
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
	Paysalphanumcurrency sql.NullString
	Paysissuer           sql.NullString
	Getsalphanumcurrency sql.NullString
	Getsissuer           sql.NullString
	Amount               int64
	Pricen               int32
	Priced               int32
	Price                int64
}

// PagingToken returns a suitable paging token for the CoreOfferRecord
func (r CoreOfferRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Offerid)
}

// PriceAsFloat return the price fraction as a floating point approximate.
func (r CoreOfferRecord) PriceAsFloat() float64 {
	return float64(r.Pricen) / float64(r.Priced)
}
