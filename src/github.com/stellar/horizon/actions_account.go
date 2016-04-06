package horizon

import (
	"github.com/stellar/horizon/db2"
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
	PagingParams db2.PageQuery
	Records      []history.Account
	Page         hal.Page
}

// JSON is a method for actions.JSON
func (action *AccountIndexAction) JSON() {
	action.Do(
		action.loadParams,
		action.loadRecords,
		action.loadPage,
		func() { hal.Render(action.W, action.Page) },
	)
}

// SSE is a method for actions.SSE
func (action *AccountIndexAction) SSE(stream sse.Stream) {
	action.Setup(action.loadParams)
	action.Do(
		action.loadRecords,
		func() {
			stream.SetLimit(int(action.PagingParams.Limit))
			var res resource.HistoryAccount
			for _, record := range action.Records[stream.SentCount():] {
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: record.PagingToken(), Data: res})
			}
		},
	)
}

func (action *AccountIndexAction) loadParams() {
	action.ValidateCursorAsDefault()
	action.PagingParams = action.GetPageQuery()
}

func (action *AccountIndexAction) loadRecords() {
	action.Err = action.HistoryQ().
		Accounts().
		Page(action.PagingParams).
		Select(&action.Records)
}

// LoadPage populates action.Page
func (action *AccountIndexAction) loadPage() {
	for _, record := range action.Records {
		var res resource.HistoryAccount
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}
	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = "/accounts"
	action.Page.Limit = action.PagingParams.Limit
	action.Page.Cursor = action.PagingParams.Cursor
	action.Page.Order = action.PagingParams.Order
	action.Page.PopulateLinks()
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
