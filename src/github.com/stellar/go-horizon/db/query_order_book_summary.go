package db

import (
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

// OrderBookSummaryPageSize is the default limit of price levels returned per "side" of an order book
const OrderBookSummaryPageSize = 20

// OrderBookSummarySQL is the raw sql query (postgresql style placeholders) to query for
// a summary of price levels for a given order book.
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
	LIMIT $7 

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
	LIMIT $7
)) summary

ORDER BY type, pricef
`

// OrderBookSummaryQuery is a query from which you should be able to drive a
// order book summary client interface (bid/ask spread, prices and volume, etc).
type OrderBookSummaryQuery struct {
	SqlQuery
	SellingType   xdr.AssetType
	SellingCode   string
	SellingIssuer string
	BuyingType    xdr.AssetType
	BuyingCode    string
	BuyingIssuer  string
}

// Invert returns a new query in which the bids/asks have swapped places.
func (q OrderBookSummaryQuery) Invert() OrderBookSummaryQuery {

	return OrderBookSummaryQuery{
		SqlQuery:      q.SqlQuery,
		SellingType:   q.BuyingType,
		SellingCode:   q.BuyingCode,
		SellingIssuer: q.BuyingIssuer,
		BuyingType:    q.SellingType,
		BuyingCode:    q.SellingCode,
		BuyingIssuer:  q.SellingIssuer,
	}
}

// Select executes the query, populating the provided OrderBookSummaryRecord with data.
func (q OrderBookSummaryQuery) Select(ctx context.Context, dest interface{}) error {
	args := []interface{}{
		q.SellingType,
		q.SellingCode,
		q.SellingIssuer,
		q.BuyingType,
		q.BuyingCode,
		q.BuyingIssuer,
		OrderBookSummaryPageSize,
	}

	return q.SqlQuery.SelectRaw(ctx, OrderBookSummarySQL, args, dest)
}
