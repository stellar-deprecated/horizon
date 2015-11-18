package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// OrderBookShowAction renders a account summary found by its address.
type OrderBookShowAction struct {
	Action
	Query    *db.OrderBookSummaryQuery
	Record   db.OrderBookSummaryRecord
	Resource resource.OrderBookSummary
}

// LoadQuery sets action.Query from the request params
func (action *OrderBookShowAction) LoadQuery() {
	params := action.GetOrderBook()

	action.Query = &db.OrderBookSummaryQuery{
		SqlQuery:      action.App.CoreQuery(),
		SellingType:   params.SellingType,
		SellingIssuer: params.SellingIssuer,
		SellingCode:   params.SellingCode,
		BuyingType:    params.BuyingType,
		BuyingIssuer:  params.BuyingIssuer,
		BuyingCode:    params.BuyingCode,
	}

	return
}

// LoadRecord populates action.Record
func (action *OrderBookShowAction) LoadRecord() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Record)
}

// LoadResource populates action.Record
func (action *OrderBookShowAction) LoadResource() {
	action.Err = action.Resource.Populate(action.Ctx, action.Query, action.Record)
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
		stream.Send(sse.Event{
			Data: action.Resource,
		})

		if stream.SentCount() >= 10 {
			stream.Done()
		}
	})

}
