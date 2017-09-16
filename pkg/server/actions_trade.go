package server

import (
	"errors"

	"fmt"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/pkg/db2"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/render/hal"
	"github.com/stellar/horizon/pkg/resource"
)

type TradeIndexAction struct {
	Action
	OfferFilter       int64
	SoldAssetFilter   xdr.Asset
	BoughtAssetFilter xdr.Asset
	PagingParams      db2.PageQuery
	Records           []history.Trade
	Ledgers           history.LedgerCache
	Page              hal.Page
}

// JSON is a method for actions.JSON
func (action *TradeIndexAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.loadRecords,
		action.loadLedgers,
		action.loadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *TradeIndexAction) loadParams() {
	action.OfferFilter = action.GetInt64("offer_id")
	action.PagingParams = action.GetPageQuery()
	action.SoldAssetFilter = action.MaybeGetAsset("sold_")
	action.BoughtAssetFilter = action.MaybeGetAsset("bought_")
}

// loadRecords populates action.Records
func (action *TradeIndexAction) loadRecords() {
	trades := action.HistoryQ().Trades()

	if action.OfferFilter > int64(0) {
		trades = trades.ForOffer(action.OfferFilter)
	}

	if (action.SoldAssetFilter != xdr.Asset{}) {
		trades = trades.ForSoldAsset(action.SoldAssetFilter)
	}

	if (action.BoughtAssetFilter != xdr.Asset{}) {
		trades = trades.ForBoughtAsset(action.BoughtAssetFilter)
	}

	action.Err = trades.Page(action.PagingParams).Select(&action.Records)
}

// loadLedgers populates the ledger cache for this action
func (action *TradeIndexAction) loadLedgers() {
	if action.Err != nil {
		return
	}

	for _, trade := range action.Records {
		action.Ledgers.Queue(trade.LedgerSequence())
	}

	action.Err = action.Ledgers.Load(action.HistoryQ())
}

// loadPage populates action.Page
func (action *TradeIndexAction) loadPage() {
	for _, record := range action.Records {
		var res resource.Trade

		ledger, found := action.Ledgers.Records[record.LedgerSequence()]
		if !found {
			msg := fmt.Sprintf("could not find ledger data for sequence %d", record.LedgerSequence())
			action.Err = errors.New(msg)
			return
		}

		action.Err = res.Populate(action.Ctx, record, ledger)
		if action.Err != nil {
			return
		}

		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.PagingParams.Limit
	action.Page.Cursor = action.PagingParams.Cursor
	action.Page.Order = action.PagingParams.Order
	action.Page.PopulateLinks()
}

type TradeEffectIndexAction struct {
	Action
	AccountFilter string
	PagingParams  db2.PageQuery
	Records       []history.Effect
	Ledgers       history.LedgerCache
	Page          hal.Page
}

// JSON is a method for actions.JSON
func (action *TradeEffectIndexAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.loadRecords,
		action.loadLedgers,
		action.loadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// loadLedgers populates the ledger cache for this action
func (action *TradeEffectIndexAction) loadLedgers() {
	if action.Err != nil {
		return
	}

	for _, trade := range action.Records {
		action.Ledgers.Queue(trade.LedgerSequence())
	}

	action.Err = action.Ledgers.Load(action.HistoryQ())
}

func (action *TradeEffectIndexAction) loadParams() {
	action.AccountFilter = action.GetString("account_id")
	action.PagingParams = action.GetPageQuery()
}

func (action *TradeEffectIndexAction) loadRecords() {
	trades := action.HistoryQ().Effects().OfType(history.EffectTrade).ForAccount(action.AccountFilter)

	action.Err = trades.Page(action.PagingParams).Select(&action.Records)
}

// loadPage populates action.Page
func (action *TradeEffectIndexAction) loadPage() {
	for _, record := range action.Records {
		var res resource.Trade

		ledger, found := action.Ledgers.Records[record.LedgerSequence()]
		if !found {
			msg := fmt.Sprintf("could not find ledger data for sequence %d", record.LedgerSequence())
			action.Err = errors.New(msg)
			return
		}

		action.Err = res.PopulateFromEffect(action.Ctx, record, ledger)
		if action.Err != nil {
			return
		}

		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.PagingParams.Limit
	action.Page.Cursor = action.PagingParams.Cursor
	action.Page.Order = action.PagingParams.Order
	action.Page.PopulateLinks()
}
