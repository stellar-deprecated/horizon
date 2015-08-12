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
	SellingAssetType   xdr.CurrencyType
	SellingAssetCode   string
	SellingIssuer string
	BuyingAssetType   xdr.CurrencyType
	BuyingAssetCode   string
	BuyingIssuer string
}

func (q CoreOfferPageByCurrencyQuery) Select(ctx context.Context, dest interface{}) error {
	sql := CoreOfferRecordSelect.Limit(uint64(q.Limit))

	switch q.SellingAssetType {
	case xdr.CurrencyTypeCurrencyTypeNative:
		sql = sql.Where("co.sellingissuer IS NULL")
	case xdr.CurrencyTypeCurrencyTypeAlphanum:
		sql = sql.
			Where("co.sellingissuer = ?", q.SellingIssuer).
			Where("co.sellingassetcode = ?", q.SellingAssetCode)
	}

	switch q.BuyingAssetType {
	case xdr.CurrencyTypeCurrencyTypeNative:
		sql = sql.Where("co.buyingissuer IS NULL")
	case xdr.CurrencyTypeCurrencyTypeAlphanum:
		sql = sql.
			Where("co.buyingissuer = ?", q.BuyingIssuer).
			Where("co.buyingassetcode = ?", q.BuyingAssetCode)
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
