package db

import (
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

const OrderBookSummaryPageSize = 20

const OrderBookSummarySQL = `
SELECT 
	*,
	(pricen :: double precision / priced :: double precision) as pricef

FROM
((
	-- This query returns the "asks" portion of the summary, and it is very straightforward
	SELECT 
		'ask' as type,
		co.pricen,
		co.priced,
		SUM(co.amount) as amount

	FROM  offers co

	WHERE co.sellingassettype = $1
	AND   co.sellingassetcode = $2
	AND   co.sellingissuer    = $3
	AND   co.buyingassettype  = $4
	AND   co.buyingassetcode  = $5
	AND   co.buyingissuer     = $6

	GROUP BY
		co.pricen,
		co.priced,
		co.price
	LIMIT 15

) UNION (
	-- This query returns the "bids" portion, inverting the where clauses
	-- and the pricen/priced.  This inversion is necessary to produce the "bid"
	-- view of a given offer (which are stored in the db as an offer to sell)
	SELECT 
		'bid'  as type,
		co.priced as pricen,
		co.pricen as priced,
		SUM(co.amount) as amount

	FROM offers co

	WHERE co.sellingassettype = $4
	AND   co.sellingassetcode = $5
	AND   co.sellingissuer    = $6
	AND   co.buyingassettype  = $1
	AND   co.buyingassetcode  = $2
	AND   co.buyingissuer     = $3

	GROUP BY
		co.pricen,
		co.priced,
		co.price
	LIMIT 15
)) summary

ORDER BY type, pricef
`

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
	args := []interface{}{
		q.BaseType,
		q.BaseCode,
		q.BaseIssuer,
		q.CounterType,
		q.CounterCode,
		q.CounterIssuer,
	}

	return q.SqlQuery.SelectRaw(ctx, OrderBookSummarySQL, args, dest)
}
