package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-stellar-base/xdr"
)

// OrderBookShowAction renders a account summary found by its address.
type OrderBookShowAction struct {
	Action
	Query    db.OrderBookSummaryQuery
	Record   db.OrderBookSummaryRecord
	Resource OrderBookSummaryResource
}

// LoadQuery sets action.Query from the request params
func (action *OrderBookShowAction) LoadQuery() {
	action.Query = db.OrderBookSummaryQuery{
		SqlQuery:      action.App.CoreQuery(),
		SellingType:   action.GetAssetType("selling_type"),
		SellingIssuer: action.GetString("selling_issuer"),
		SellingCode:   action.GetString("selling_code"),
		BuyingType:    action.GetAssetType("buying_type"),
		BuyingIssuer:  action.GetString("buying_issuer"),
		BuyingCode:    action.GetString("buying_code"),
	}

	if action.Err != nil {
		goto InvalidOrderBook
	}

	if action.Query.SellingType != xdr.AssetTypeAssetTypeNative {
		if action.Query.SellingCode == "" {
			goto InvalidOrderBook
		}

		if action.Query.SellingIssuer == "" {
			goto InvalidOrderBook
		}
	}

	if action.Query.BuyingType != xdr.AssetTypeAssetTypeNative {
		if action.Query.BuyingCode == "" {
			goto InvalidOrderBook
		}

		if action.Query.BuyingIssuer == "" {
			goto InvalidOrderBook
		}
	}

	return

InvalidOrderBook:
	action.Err = &problem.P{
		Type:   "invalid_order_book",
		Title:  "Invalid Order Book Parameters",
		Status: http.StatusBadRequest,
		Detail: "The parameters that specify what order book to view are invalid in some way. " +
			"Please ensure that your type parameters (selling_type and buying_type) are one the " +
			"following valid values: native, credit_alphanum4, credit_alphanum12.  Also ensure that you " +
			"have specified selling_code and selling_issuer if selling_type is not 'native', as well " +
			"as buying_code and buying_issuer if buying_type is not 'native'",
	}

	return
}

// LoadRecord populates action.Record
func (action *OrderBookShowAction) LoadRecord() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Record)
}

// LoadResource populates action.Record
func (action *OrderBookShowAction) LoadResource() {
	action.Resource, action.Err = NewOrderBookSummaryResource(action.Query, action.Record)
}

// JSON is a method for actions.JSON
func (action *OrderBookShowAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecord, action.LoadResource)

	action.Do(func() {
		hal.Render(action.W, action.Resource)
	})
}
