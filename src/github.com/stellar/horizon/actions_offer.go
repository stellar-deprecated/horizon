package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// This file contains the actions:

// OffersByAccountAction renders a page of offer resources, for a given
// account.  These offers are present in the ledger as of the latest validated
// ledger.
type OffersByAccountAction struct {
	Action
	Query   db.CoreOfferPageByAddressQuery
	Records []db.CoreOfferRecord
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *OffersByAccountAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// SSE is a method for actions.SSE
func (action *OffersByAccountAction) SSE(stream sse.Stream) {
	stream.SetLimit(int(action.Query.Limit))
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		func() {
			for _, record := range action.Records[stream.SentCount():] {
				var res resource.Offer
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: res.PagingToken(), Data: res})
			}
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *OffersByAccountAction) LoadQuery() {
	action.Query = db.CoreOfferPageByAddressQuery{
		SqlQuery:  action.App.CoreQuery(),
		PageQuery: action.GetPageQuery(),
		Address:   action.GetString("account_id"),
	}
}

// LoadRecords populates action.Records
func (action *OffersByAccountAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *OffersByAccountAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.Offer
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}

	action.Page.Host = action.R.Host
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}
