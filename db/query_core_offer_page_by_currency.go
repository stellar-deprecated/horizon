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
	TakerPaysType   xdr.CurrencyType
	TakerPaysCode   string
	TakerPaysIssuer string
	TakerGetsType   xdr.CurrencyType
	TakerGetsCode   string
	TakerGetsIssuer string
}

func (q CoreOfferPageByCurrencyQuery) Get(ctx context.Context) ([]interface{}, error) {
	sql := CoreOfferRecordSelect.Limit(uint64(q.Limit))

	switch q.TakerPaysType {
	case xdr.CurrencyTypeCurrencyTypeNative:
		sql = sql.Where("co.paysissuer IS NULL")
	case xdr.CurrencyTypeCurrencyTypeAlphanum:
		sql = sql.
			Where("co.paysissuer = ?", q.TakerPaysIssuer).
			Where("co.paysalphanumcurrency = ?", q.TakerPaysCode)
	}

	switch q.TakerGetsType {
	case xdr.CurrencyTypeCurrencyTypeNative:
		sql = sql.Where("co.getsissuer IS NULL")
	case xdr.CurrencyTypeCurrencyTypeAlphanum:
		sql = sql.
			Where("co.getsissuer = ?", q.TakerGetsIssuer).
			Where("co.getsalphanumcurrency = ?", q.TakerGetsCode)
	}

	switch q.Order {
	case "asc":
		sql = sql.Where("co.price > ?", q.Cursor).OrderBy("co.price asc")
	case "desc":
		sql = sql.Where("co.price < ?", q.Cursor).OrderBy("co.price desc")
	}

	var records []CoreOfferRecord
	err := q.SqlQuery.Select(ctx, sql, &records)
	return makeResult(records), err

}

func (q CoreOfferPageByCurrencyQuery) IsComplete(ctx context.Context, alreadyDelivered int) bool {
	return alreadyDelivered >= int(q.Limit)
}
