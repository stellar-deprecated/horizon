package horizon

import (
	"fmt"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/sse"
)

// This file contains the actions:
//
// OfferIndexAction: pages of offers for an account

// OffersByAccountAction renders a page of offer resources, for a given
// account.  These offers are present in the ledger as of the latest validated
// ledger.
type OffersByAccountAction struct {
	Action
	Query   db.CoreOfferPageByAddressQuery
	Records []db.CoreOfferRecord
	Page    hal.Page
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
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *OffersByAccountAction) LoadPage() {
	action.LoadRecords()
	if action.Err != nil {
		return
	}

	prefix := fmt.Sprintf("/accounts/%s", action.GetString("account_id"))
	action.Page, action.Err = NewOfferResourcePage(action.Records, action.Query.PageQuery, prefix)
}

// JSON is a method for actions.JSON
func (action *OffersByAccountAction) JSON() {
	action.LoadPage()
	if action.Err != nil {
		return
	}
	hal.Render(action.W, action.Page)
}

// SSE is a method for actions.SSE
func (action *OffersByAccountAction) SSE(stream sse.Stream) {
	action.LoadRecords()
	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	for _, record := range action.Records[stream.SentCount():] {
		stream.Send(sse.Event{
			ID:   record.PagingToken(),
			Data: NewOfferResource(record),
		})
	}

	if stream.SentCount() >= int(action.Query.Limit) {
		stream.Done()
	}
}
