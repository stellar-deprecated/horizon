package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/resource"
)

// TradeIndexAction renders a page of effect resources, filtered to include
// only trades, identified by a normal page query and optionally filtered by an account
// or order book
type TradeIndexAction struct {
	Action
	Query   db.EffectPageQuery
	Records []db.EffectRecord
	Page    hal.NewPage
}

// JSON is a method for actions.JSON
func (action *TradeIndexAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *TradeIndexAction) LoadQuery() {
	action.Query = db.EffectPageQuery{
		SqlQuery:  action.App.HistoryQuery(),
		PageQuery: action.GetPageQuery(),
		Filter:    &db.EffectTypeFilter{db.EffectTrade},
	}

	if address := action.GetString("account_id"); address != "" {
		action.Query.Filter = db.FilterAll(
			action.Query.Filter,
			&db.EffectAccountFilter{action.Query.SqlQuery, address},
		)
		return
	}

	// HACK: see if it looks like we're specifying an order book on params
	// try to load it if so
	if action.GetString("selling_asset_type") != "" {
		params := action.GetOrderBook()

		action.Query.Filter = db.FilterAll(
			action.Query.Filter,
			&db.EffectOrderBookFilter{
				SellingType:   params.SellingType,
				SellingCode:   params.SellingCode,
				SellingIssuer: params.SellingIssuer,
				BuyingType:    params.BuyingType,
				BuyingCode:    params.BuyingCode,
				BuyingIssuer:  params.BuyingIssuer,
			},
		)
	}

}

// LoadRecords populates action.Records
func (action *TradeIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *TradeIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.Trade
		action.Err = res.Populate(record)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}

	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}
