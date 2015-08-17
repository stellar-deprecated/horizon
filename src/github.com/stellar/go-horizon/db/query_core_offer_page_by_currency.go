package db

import (
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

// CoreOfferPageByAddressQuery loads a page of active offers for the given
// address.
type CoreOfferPageByCurrencyQuery struct {
	SqlQuery
	PageQuery
	BuyingAssetType  xdr.AssetType
	BuyingAssetCode  string
	BuyingIssuer     string
	SellingAssetType xdr.AssetType
	SellingAssetCode string
	SellingIssuer    string
}

func (q CoreOfferPageByCurrencyQuery) Select(ctx context.Context, dest interface{}) error {
	sql := CoreOfferRecordSelect.
		Limit(uint64(q.Limit)).
		Where("co.buyingassettype = ?", q.BuyingAssetType).
		Where("co.sellingassettype = ?", q.SellingAssetType)

	if q.BuyingAssetType != xdr.AssetTypeAssetTypeNative {
		sql = sql.
			Where("co.buyingissuer = ?", q.BuyingIssuer).
			Where("co.buyingassetcode = ?", q.BuyingAssetCode)
	}

	if q.SellingAssetType != xdr.AssetTypeAssetTypeNative {
		sql = sql.
			Where("co.sellingissuer = ?", q.SellingIssuer).
			Where("co.sellingassetcode = ?", q.SellingAssetCode)
	}

	cursor, err := q.CursorInt64()
	if err != nil {
		return err
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("co.price > ?", cursor).OrderBy("co.price asc")
	case "desc":
		sql = sql.Where("co.price < ?", cursor).OrderBy("co.price desc")
	}

	return q.SqlQuery.Select(ctx, sql, dest)
}
