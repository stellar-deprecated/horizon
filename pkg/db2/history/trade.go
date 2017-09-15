package history

import (
	"fmt"
	"math"

	sq "github.com/Masterminds/squirrel"
	"github.com/stellar/go/support/errors"
	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/pkg/db2"
	toid "github.com/stellar/horizon/pkg/toid"
)

// LedgerSequence return the ledger in which the effect occurred.
func (r *Trade) LedgerSequence() int32 {
	id := toid.Parse(r.HistoryOperationID)
	return id.LedgerSequence
}

// PagingToken returns a cursor for this effect
func (r *Trade) PagingToken() string {
	return fmt.Sprintf("%d-%d", r.HistoryOperationID, r.Order)
}

// Trades provides a helper to filter rows from the `history_trades` table
// with pre-defined filters.  See `TradesQ` methods for the available filters.
func (q *Q) Trades() *TradesQ {
	return &TradesQ{
		parent: q,
		sql:    selectTrade,
	}
}

// ForBoughtAsset filters the query to only include trades involving that
// involved selling the provided asset.
func (q *TradesQ) ForBoughtAsset(bought xdr.Asset) *TradesQ {
	q.orderBookFilter(bought, "bought_")
	if q.Err != nil {
		return q
	}

	return q
}

// ForOffer filters the trade query to only return trades that occurred against
// the offer identified by `id`.
func (q *TradesQ) ForOffer(id int64) *TradesQ {
	q.sql = q.sql.Where("htrd.offer_id = ?", id)
	return q
}

// ForSoldAsset filters the query to only include trades involving that involved
// selling the provided asset.
func (q *TradesQ) ForSoldAsset(sold xdr.Asset) *TradesQ {
	q.orderBookFilter(sold, "sold_")
	if q.Err != nil {
		return q
	}

	return q
}

// Page specifies the paging constraints for the query being built by `q`.
func (q *TradesQ) Page(page db2.PageQuery) *TradesQ {
	if q.Err != nil {
		return q
	}

	op, idx, err := page.CursorInt64Pair(db2.DefaultPairSep)
	if err != nil {
		q.Err = err
		return q
	}

	// constrain the second portion of the cursor pair to 32-bits
	if idx > math.MaxInt32 {
		idx = math.MaxInt32
	}

	switch page.Order {
	case "asc":
		q.sql = q.sql.
			Where(`(
					 htrd.history_operation_id > ?
				OR (
							htrd.history_operation_id = ?
					AND htrd.order > ?
				))`, op, op, idx).
			OrderBy("htrd.history_operation_id asc, htrd.order asc")
	case "desc":
		q.sql = q.sql.
			Where(`(
					 htrd.history_operation_id < ?
				OR (
							htrd.history_operation_id = ?
					AND htrd.order < ?
				))`, op, op, idx).
			OrderBy("htrd.history_operation_id desc, htrd.order desc")
	}

	q.sql = q.sql.Limit(page.Limit)
	return q
}

// Select loads the results of the query specified by `q` into `dest`.
func (q *TradesQ) Select(dest interface{}) error {
	if q.Err != nil {
		return q.Err
	}

	q.Err = q.parent.Select(dest, q.sql)
	return q.Err
}

var selectTrade = sq.Select(
	"htrd.history_operation_id",
	"htrd.order",
	"htrd.offer_id",
	"hacc1.address as seller_address",
	"hacc2.address as buyer_address",
	"htrd.sold_asset_type",
	"htrd.sold_asset_code",
	"htrd.sold_asset_issuer",
	"htrd.sold_amount",
	"htrd.bought_asset_type",
	"htrd.bought_asset_code",
	"htrd.bought_asset_issuer",
	"htrd.bought_amount",
).From("history_trades htrd").
	LeftJoin("history_accounts hacc1 ON hacc1.id = htrd.seller_id").
	LeftJoin("history_accounts hacc2 ON hacc2.id = htrd.buyer_id")

func (q *TradesQ) orderBookFilter(a xdr.Asset, prefix string) {
	var typ, code, iss string
	err := a.Extract(&typ, &code, &iss)
	if err != nil {
		q.Err = errors.Wrap(err, "failed to extract filter asset")
		return
	}

	if !(prefix == "bought_" || prefix == "sold_") {
		panic("invalid prefix: only bought_ and sold_ allowed")
	}

	clause := fmt.Sprintf(
		`(htrd.%sasset_type = ? 
		AND htrd.%sasset_code = ? 
		AND htrd.%sasset_issuer = ?)`, prefix, prefix, prefix)
	q.sql = q.sql.Where(clause, typ, code, iss)
}
