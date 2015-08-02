package db

import (
	"database/sql"
	"fmt"

	sq "github.com/lann/squirrel"
)

// CoreOfferRecordSelect is a sql fragment to help select form queries that
// select into a CoreOfferRecord
var CoreOfferRecordSelect = sq.Select("co.*").From("offers co")

// CoreOfferRecord is row of data from the `offers` table from stellar-core
type CoreOfferRecord struct {
	Accountid            string         `db:"sellerid"`
	Offerid              int64          `db:"offerid"`
	SellingAssetType     sql.NullString `db:"sellingassettype"`
	SellingAssetCode     sql.NullString `db:"sellingassetcode"`
	SellingIssuer        sql.NullString `db:"sellingissuer"`
	BuyingAssetType      sql.NullString `db:"buyingassettype"`
	BuyingAssetCode      sql.NullString `db:"buyingassetcode"`
	BuyingIssuer         sql.NullString `db:"buyingissuer"`
	Amount               int64          `db:"amount"`
	Pricen               int32          `db:"pricen"`
	Priced               int32          `db:"priced"`
	Price                int64          `db:"price"`
	Flags                int32          `db:"flags"`
}

// PagingToken returns a suitable paging token for the CoreOfferRecord
func (r CoreOfferRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Offerid)
}

// PriceAsFloat return the price fraction as a floating point approximate.
func (r CoreOfferRecord) PriceAsFloat() float64 {
	return float64(r.Pricen) / float64(r.Priced)
}
