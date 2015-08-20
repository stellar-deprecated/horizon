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
		BaseType:      action.GetAssetType("base_type"),
		BaseIssuer:    action.GetString("base_issuer"),
		BaseCode:      action.GetString("base_code"),
		CounterType:   action.GetAssetType("counter_type"),
		CounterIssuer: action.GetString("counter_issuer"),
		CounterCode:   action.GetString("counter_code"),
	}

	if action.Err != nil {
		goto InvalidOrderBook
	}

	if action.Query.BaseType != xdr.AssetTypeAssetTypeNative {
		if action.Query.BaseCode == "" {
			goto InvalidOrderBook
		}

		if action.Query.BaseIssuer == "" {
			goto InvalidOrderBook
		}
	}

	if action.Query.CounterType != xdr.AssetTypeAssetTypeNative {
		if action.Query.CounterCode == "" {
			goto InvalidOrderBook
		}

		if action.Query.CounterIssuer == "" {
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
			"Please ensure that your type parameters (base_type and counter_type) are one the " +
			"following valid values: native, alphanum_4, alphanum_12.  Also ensure that you " +
			"have specified base_code and base_issuer if base_type is not 'native', as well " +
			"as counter_code and counter_issuer if counter_type is not 'native'",
	}

	return
}

// LoadRecord populates action.Record
func (action *OrderBookShowAction) LoadRecord() {
	action.Err = db.Get(action.Ctx, action.Query, &action.Record)
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
