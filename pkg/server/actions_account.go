package server

import (
	"github.com/stellar/horizon/pkg/db2/core"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/render/hal"
	"github.com/stellar/horizon/pkg/render/sse"
	"github.com/stellar/horizon/pkg/resource"
)

// This file contains the actions:
//
// AccountShowAction: details for single account (including stellar-core state)

// AccountShowAction renders a account summary found by its address.
type AccountShowAction struct {
	Action
	Address        string
	HistoryRecord  history.Account
	CoreData       []core.AccountData
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
		AllDataByAddress(&action.CoreData, action.Address)
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

	// Do not fail when we cannot find the history record... it probably just
	// means that the account was created outside of our known history range.
	if action.HistoryQ().NoRows(action.Err) {
		action.Err = nil
	}

	if action.Err != nil {
		return
	}
}

func (action *AccountShowAction) loadResource() {
	action.Err = action.Resource.Populate(
		action.Ctx,
		action.CoreRecord,
		action.CoreData,
		action.CoreSigners,
		action.CoreTrustlines,
		action.HistoryRecord,
	)
}
