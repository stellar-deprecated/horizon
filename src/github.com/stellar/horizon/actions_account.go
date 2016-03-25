package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
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
		SqlQuery:  action.App.HorizonQuery(),
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
	Address        string
	HistoryRecord  history.Account
	CoreRecord     core.Account
	CoreSigners    []core.Signer
	CoreTrustlines []core.Trustline
	Resource       resource.Account
}

// JSON is a method for actions.JSON
func (action *AccountShowAction) JSON() {
	action.Do(
		action.loadParams,
		action.loadRecord,
		action.loadResource,
		func() {
			hal.Render(action.W, action.Resource)
		},
	)
}

// SSE is a method for actions.SSE
func (action *AccountShowAction) SSE(stream sse.Stream) {
	action.Do(
		action.loadParams,
		action.loadRecord,
		action.loadResource,
		func() {
			stream.SetLimit(10)
			stream.Send(sse.Event{Data: action.Resource})
		},
	)
}

func (action *AccountShowAction) loadParams() {
	action.Address = action.GetString("id")
}

func (action *AccountShowAction) loadRecord() {
	action.Err = action.CoreQ().
		AccountByAddress(&action.CoreRecord, action.Address)
	if action.Err != nil {
		return
	}

	action.Err = action.CoreQ().
		SignersByAddress(&action.CoreSigners, action.Address)
	if action.Err != nil {
		return
	}

	action.Err = action.CoreQ().
		TrustlinesByAddress(&action.CoreTrustlines, action.Address)
	if action.Err != nil {
		return
	}

	action.Err = action.HistoryQ().
		AccountByAddress(&action.HistoryRecord, action.Address)
	if action.Err != nil {
		return
	}
}

func (action *AccountShowAction) loadResource() {
	action.Err = action.Resource.Populate(
		action.Ctx,
		action.CoreRecord,
		action.CoreSigners,
		action.CoreTrustlines,
		action.HistoryRecord,
	)
}
