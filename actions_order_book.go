package horizon

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// OrderBookShowAction renders a account summary found by its address.
type OrderBookShowAction struct {
	Action
	Selling  xdr.Asset
	Buying   xdr.Asset
	Record   core.OrderBookSummary
	Resource resource.OrderBookSummary
}

// LoadQuery sets action.Query from the request params
func (action *OrderBookShowAction) LoadQuery() {
	action.Selling = action.GetAsset("selling_")
	action.Buying = action.GetAsset("buying_")

	if action.Err != nil {
		action.Err = &problem.P{
			Type:   "invalid_order_book",
			Title:  "Invalid Order Book Parameters",
			Status: http.StatusBadRequest,
			Detail: "The parameters that specify what order book to view are invalid in some way. " +
				"Please ensure that your type parameters (selling_asset_type and buying_asset_type) are one the " +
				"following valid values: native, credit_alphanum4, credit_alphanum12.  Also ensure that you " +
				"have specified selling_asset_code and selling_issuer if selling_asset_type is not 'native', as well " +
				"as buying_asset_code and buying_issuer if buying_asset_type is not 'native'",
		}
	}
}

// LoadRecord populates action.Record
func (action *OrderBookShowAction) LoadRecord() {
	action.Err = action.CoreQ().GetOrderBookSummary(
		&action.Record,
		action.Selling,
		action.Buying,
	)
}

// LoadResource populates action.Record
func (action *OrderBookShowAction) LoadResource() {
	action.Err = action.Resource.Populate(
		action.Ctx,
		action.Selling,
		action.Buying,
		action.Record,
	)
}

// JSON is a method for actions.JSON
func (action *OrderBookShowAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecord, action.LoadResource)

	action.Do(func() {
		hal.Render(action.W, action.Resource)
	})
}

// SSE is a method for actions.SSE
func (action *OrderBookShowAction) SSE(stream sse.Stream) {
	action.Do(action.LoadQuery, action.LoadRecord, action.LoadResource)

	action.Do(func() {
		stream.SetLimit(10)
		stream.Send(sse.Event{
			Data: action.Resource,
		})
	})

}

type OrderBookTradeIndexAction struct {
	Action
	Selling      xdr.Asset
	Buying       xdr.Asset
	PagingParams db2.PageQuery
	Records      []history.Effect
	Ledgers      history.LedgerCache
	Page         hal.Page
}

// JSON is a method for actions.JSON
func (action *OrderBookTradeIndexAction) JSON() {
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
func (action *OrderBookTradeIndexAction) loadLedgers() {
	for _, trade := range action.Records {
		action.Ledgers.Queue(trade.LedgerSequence())
	}

	action.Err = action.Ledgers.Load(action.HistoryQ())
}

func (action *OrderBookTradeIndexAction) loadParams() {
	action.PagingParams = action.GetPageQuery()
	action.Selling = action.GetAsset("selling_")
	action.Buying = action.GetAsset("buying_")
}

func (action *OrderBookTradeIndexAction) loadRecords() {
	trades := action.HistoryQ().Effects().OfType(history.EffectTrade).ForOrderBook(action.Selling, action.Buying)

	action.Err = trades.Page(action.PagingParams).Select(&action.Records)
}

// loadPage populates action.Page
func (action *OrderBookTradeIndexAction) loadPage() {
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
