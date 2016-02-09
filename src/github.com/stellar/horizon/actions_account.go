package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// This file contains the actions:
//
// AccountIndexAction: pages of account's addresses in order of creation
// AccountShowAction: details for single account (including stellar-core state)

// AccountIndexAction renders a page of account resources, identified by
// a normal page query, ordered by the operation id that created them.
type AccountIndexAction struct {
	Action
	Query   db.HistoryAccountPageQuery
	Records []history.Account
	Page    hal.Page
}

// LoadQuery sets action.Query from the request params
func (action *AccountIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.HistoryAccountPageQuery{
		SqlQuery:  action.App.HistoryQuery(),
		PageQuery: action.GetPageQuery(),
	}
}

// LoadRecords populates action.Records
func (action *AccountIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *AccountIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.HistoryAccount
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}
	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = "/accounts"
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}

// JSON is a method for actions.JSON
func (action *AccountIndexAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() { hal.Render(action.W, action.Page) },
	)
}

// SSE is a method for actions.SSE
func (action *AccountIndexAction) SSE(stream sse.Stream) {
	action.Setup(action.LoadQuery)
	action.Do(
		action.LoadRecords,
		func() {
			stream.SetLimit(int(action.Query.Limit))
			var res resource.HistoryAccount
			for _, record := range action.Records[stream.SentCount():] {
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: record.PagingToken(), Data: res})
			}
		},
	)
}

// AccountShowAction renders a account summary found by its address.
type AccountShowAction struct {
	Action
	Query    db.AccountByAddressQuery
	Record   db.AccountRecord
	Resource resource.Account
}

// JSON is a method for actions.JSON
func (action *AccountShowAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecord,
		action.LoadResource,
		func() {
			hal.Render(action.W, action.Resource)
		},
	)
}

// SSE is a method for actions.SSE
func (action *AccountShowAction) SSE(stream sse.Stream) {
	action.Do(
		action.LoadQuery,
		action.LoadRecord,
		action.LoadResource,
		func() {
			stream.SetLimit(10)
			stream.Send(sse.Event{Data: action.Resource})
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *AccountShowAction) LoadQuery() {
	action.Query = db.AccountByAddressQuery{
		Core:    action.App.CoreQuery(),
		History: action.App.HistoryQuery(),
		Address: action.GetString("id"),
	}
}

// LoadRecord populates action.Record
func (action *AccountShowAction) LoadRecord() {
	action.Err = db.Get(action.Ctx, action.Query, &action.Record)
}

// LoadResource populates action.Resource
func (action *AccountShowAction) LoadResource() {
	action.Err = action.Resource.Populate(action.Ctx, action.Record)
}
