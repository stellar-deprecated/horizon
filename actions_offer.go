package horizon

import (
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/core"
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
	Address   string
	PageQuery db2.PageQuery
	Records   []core.Offer
	Page      hal.Page
}

// JSON is a method for actions.JSON
func (action *OffersByAccountAction) JSON() {
	action.Do(
		action.loadParams,
		action.loadRecords,
		action.loadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// SSE is a method for actions.SSE
func (action *OffersByAccountAction) SSE(stream sse.Stream) {
	action.Do(
		action.loadParams,
		action.loadRecords,
		func() {
			stream.SetLimit(int(action.PageQuery.Limit))
			for _, record := range action.Records[stream.SentCount():] {
				var res resource.Offer
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: res.PagingToken(), Data: res})
			}
		},
	)
}

func (action *OffersByAccountAction) loadParams() {
	action.PageQuery = action.GetPageQuery()
	action.Address = action.GetString("account_id")
}

func (action *OffersByAccountAction) loadRecords() {
	action.Err = action.CoreQ().OffersByAddress(
		&action.Records,
		action.Address,
		action.PageQuery,
	)
}

func (action *OffersByAccountAction) loadPage() {
	for _, record := range action.Records {
		var res resource.Offer
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.PageQuery.Limit
	action.Page.Cursor = action.PageQuery.Cursor
	action.Page.Order = action.PageQuery.Order
	action.Page.PopulateLinks()
}
