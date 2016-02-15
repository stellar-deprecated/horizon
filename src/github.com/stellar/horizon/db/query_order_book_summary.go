package db

import (
	"bytes"
	"fmt"
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
	"text/template"
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

	WHERE 1=1
	AND   {{ .Filter "co.sellingassettype" .SellingType }}
	AND   {{ .Filter "co.sellingassetcode" .SellingCode}}
	AND   {{ .Filter "co.sellingissuer"    .SellingIssuer}}
	AND   {{ .Filter "co.buyingassettype"  .BuyingType }}
	AND   {{ .Filter "co.buyingassetcode"  .BuyingCode}}
	AND   {{ .Filter "co.buyingissuer"     .BuyingIssuer}}

	GROUP BY
		co.pricen,
		co.priced,
		co.price
	LIMIT $1

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

	WHERE 1=1
	AND   {{ .Filter "co.sellingassettype" .BuyingType }}
	AND   {{ .Filter "co.sellingassetcode" .BuyingCode}}
	AND   {{ .Filter "co.sellingissuer"    .BuyingIssuer}}
	AND   {{ .Filter "co.buyingassettype"  .SellingType }}
	AND   {{ .Filter "co.buyingassetcode"  .SellingCode}}
	AND   {{ .Filter "co.buyingissuer"     .SellingIssuer}}

	GROUP BY
		co.pricen,
		co.priced,
		co.price
	LIMIT $1
)) summary

ORDER BY type, pricef
`

var OrderBookSummaryTemplate *template.Template

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

	args []interface{}
}

// Invert returns a new query in which the bids/asks have swapped places.
func (q *OrderBookSummaryQuery) Invert() *OrderBookSummaryQuery {

	return &OrderBookSummaryQuery{
		SqlQuery:      q.SqlQuery,
		SellingType:   q.BuyingType,
		SellingCode:   q.BuyingCode,
		SellingIssuer: q.BuyingIssuer,
		BuyingType:    q.SellingType,
		BuyingCode:    q.SellingCode,
		BuyingIssuer:  q.SellingIssuer,
	}
}

// Select executes the query, populating the provided OrderBookSummary with data.
func (q *OrderBookSummaryQuery) Select(ctx context.Context, dest interface{}) error {
	var sql bytes.Buffer

	// append the limit first to the arguments, so we can use
	// a fixed placeholder (in this case $1)
	q.pushArg(OrderBookSummaryPageSize)

	err := OrderBookSummaryTemplate.Execute(&sql, q)
	if err != nil {
		return errors.Wrap(err, 1)
	}

	err = q.SqlQuery.SelectRaw(ctx, sql.String(), q.args, dest)
	if err != nil {
		return errors.Wrap(err, 1)
	}

	return nil
}

// Filter helps manage positional parameters and "IS NULL" checks for this query.
// An empty string will be converted into a null comparison.
func (q *OrderBookSummaryQuery) Filter(col string, v interface{}) string {
	str, ok := v.(string)

	if ok && str == "" {
		return fmt.Sprintf("%s IS NULL", col)
	}

	n := q.pushArg(v)
	return fmt.Sprintf("%s = $%d", col, n)
}

// pushArg appends the provided value to this queries argument list and returns
// the placeholder position to use in a sql snippet
func (q *OrderBookSummaryQuery) pushArg(v interface{}) int {
	q.args = append(q.args, v)
	return len(q.args)
}

func init() {
	OrderBookSummaryTemplate = template.Must(template.New("sql").Parse(OrderBookSummarySQL))
}
