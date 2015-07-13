package db

import (
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

const OrderBookSummaryPageSize = 20

type OrderBookSummaryQuery struct {
	SqlQuery
	BaseType      xdr.CurrencyType
	BaseCode      string
	BaseIssuer    string
	CounterType   xdr.CurrencyType
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
		SqlQuery:        q.SqlQuery,
		PageQuery:       PageQuery{Limit: OrderBookSummaryPageSize, Order: OrderDescending},
		TakerPaysType:   q.BaseType,
		TakerPaysCode:   q.BaseCode,
		TakerPaysIssuer: q.BaseIssuer,
		TakerGetsType:   q.CounterType,
		TakerGetsCode:   q.CounterCode,
		TakerGetsIssuer: q.CounterIssuer,
	}

	asksQuery := CoreOfferPageByCurrencyQuery{
		SqlQuery:        q.SqlQuery,
		PageQuery:       PageQuery{Limit: OrderBookSummaryPageSize, Order: OrderAscending},
		TakerPaysType:   q.CounterType,
		TakerPaysCode:   q.CounterCode,
		TakerPaysIssuer: q.CounterIssuer,
		TakerGetsType:   q.BaseType,
		TakerGetsCode:   q.BaseCode,
		TakerGetsIssuer: q.BaseIssuer,
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
