package db

import (
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

const OrderBookSummaryPageSize = 20

type OrderBookSummaryQuery struct {
	SqlQuery
	BaseType      xdr.AssetType
	BaseCode      string
	BaseIssuer    string
	CounterType   xdr.AssetType
	CounterCode   string
	CounterIssuer string
}

func (q OrderBookSummaryQuery) Invert() OrderBookSummaryQuery {

	return OrderBookSummaryQuery{
		SqlQuery:      q.SqlQuery,
		BaseType:      q.CounterType,
		BaseCode:      q.CounterCode,
		BaseIssuer:    q.CounterIssuer,
		CounterType:   q.BaseType,
		CounterCode:   q.BaseCode,
		CounterIssuer: q.BaseIssuer,
	}
}

func (q OrderBookSummaryQuery) Select(ctx context.Context, dest interface{}) error {

	bidsQuery := CoreOfferPageByCurrencyQuery{
		SqlQuery:         q.SqlQuery,
		PageQuery:        PageQuery{Limit: OrderBookSummaryPageSize, Order: OrderAscending},
		BuyingAssetType:  q.BaseType,
		BuyingAssetCode:  q.BaseCode,
		BuyingIssuer:     q.BaseIssuer,
		SellingAssetType: q.CounterType,
		SellingAssetCode: q.CounterCode,
		SellingIssuer:    q.CounterIssuer,
	}

	asksQuery := CoreOfferPageByCurrencyQuery{
		SqlQuery:         q.SqlQuery,
		PageQuery:        PageQuery{Limit: OrderBookSummaryPageSize, Order: OrderAscending},
		BuyingAssetType:  q.CounterType,
		BuyingAssetCode:  q.CounterCode,
		BuyingIssuer:     q.CounterIssuer,
		SellingAssetType: q.BaseType,
		SellingAssetCode: q.BaseCode,
		SellingIssuer:    q.BaseIssuer,
	}

	result := OrderBookSummaryRecord{}

	err := Select(ctx, bidsQuery, &result.Bids)
	if err != nil {
		return err
	}

	err = Select(ctx, asksQuery, &result.Asks)
	if err != nil {
		return err
	}

	return setOn([]OrderBookSummaryRecord{result}, dest)
}
