package resource

import (
	"errors"
	"fmt"

	"github.com/stellar/go/amount"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

// PopulateFromEffect fills out the details of a trade resource from a
// history.Effect row.
func (res *Trade) PopulateFromEffect(
	ctx context.Context,
	row history.Effect,
	ledger history.Ledger,
) (err error) {
	if row.Type != history.EffectTrade {
		err = errors.New("invalid effect; not a trade")
		return
	}

	if row.LedgerSequence() != ledger.Sequence {
		err = errors.New("invalid ledger; different sequence than trade")
		return
	}

	row.UnmarshalDetails(res)
	res.ID = row.PagingToken()
	res.PT = row.PagingToken()
	res.Buyer = row.Account
	res.LedgerCloseTime = ledger.ClosedAt
	res.populateLinks(ctx, res.Seller, res.Buyer, row.HistoryOperationID)

	return
}

// Populate fills out the details of a trade using a row from the history_trades
// table.
func (res *Trade) Populate(
	ctx context.Context,
	row history.Trade,
	ledger history.Ledger,
) (err error) {

	if row.LedgerSequence() != ledger.Sequence {
		err = errors.New("invalid ledger; different sequence than trade")
		return
	}

	res.ID = row.PagingToken()
	res.PT = row.PagingToken()
	res.OfferID = fmt.Sprintf("%d", row.OfferID)
	res.Seller = row.SellerAddress
	res.Buyer = row.BuyerAddress
	res.SoldAssetType = row.SoldAssetType
	res.SoldAssetCode = row.SoldAssetCode
	res.SoldAssetIssuer = row.SoldAssetIssuer
	res.SoldAmount = amount.String(row.SoldAmount)
	res.BoughtAssetType = row.BoughtAssetType
	res.BoughtAssetCode = row.BoughtAssetCode
	res.BoughtAssetIssuer = row.BoughtAssetIssuer
	res.BoughtAmount = amount.String(row.BoughtAmount)
	res.LedgerCloseTime = ledger.ClosedAt
	res.populateLinks(ctx, res.Seller, res.Buyer, row.HistoryOperationID)

	return
}

// PagingToken implementation for hal.Pageable
func (res Trade) PagingToken() string {
	return res.PT
}

func (res *Trade) populateLinks(
	ctx context.Context,
	seller string,
	buyer string,
	opid int64,
) {
	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	res.Links.Seller = lb.Link("/accounts", res.Seller)
	res.Links.Buyer = lb.Link("/accounts", res.Buyer)
	res.Links.Operation = lb.Link(
		"/operations",
		fmt.Sprintf("%d", opid),
	)
}
