package db

import (
	"database/sql"
	"fmt"
	"math/big"

	sq "github.com/lann/squirrel"
)

// CoreOfferRecordSelect is a sql fragment to help select form queries that
// select into a CoreOfferRecord
var CoreOfferRecordSelect = sq.Select("co.*").From("offers co")

// CoreOfferRecord is row of data from the `offers` table from stellar-core
type CoreOfferRecord struct {
	SellerID string `db:"sellerid"`
	OfferID  int64  `db:"offerid"`

	SellingAssetType int32          `db:"sellingassettype"`
	SellingAssetCode sql.NullString `db:"sellingassetcode"`
	SellingIssuer    sql.NullString `db:"sellingissuer"`

	BuyingAssetType int32          `db:"buyingassettype"`
	BuyingAssetCode sql.NullString `db:"buyingassetcode"`
	BuyingIssuer    sql.NullString `db:"buyingissuer"`

	Amount       int64   `db:"amount"`
	Pricen       int32   `db:"pricen"`
	Priced       int32   `db:"priced"`
	Price        float64 `db:"price"`
	Flags        int32   `db:"flags"`
	Lastmodified int32   `db:"lastmodified"`
}

// PagingToken returns a suitable paging token for the CoreOfferRecord
func (r CoreOfferRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.OfferID)
}

// PriceAsFloat return the price fraction as a floating point approximate.
func (r CoreOfferRecord) PriceAsString() string {
	return big.NewRat(int64(r.Pricen), int64(r.Priced)).FloatString(7)
}
