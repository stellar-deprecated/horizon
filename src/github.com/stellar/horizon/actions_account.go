package horizon

import (
	"github.com/stellar/horizon/actions"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
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
	Records []db.HistoryAccountRecord
	Page    hal.Page
}

// LoadQuery sets action.Query from the request params
func (action *AccountIndexAction) LoadQuery() {
	action.ValidateInt64(actions.ParamCursor)
	action.Query = db.HistoryAccountPageQuery{
		SqlQuery:  action.App.HistoryQuery(),
		PageQuery: action.GetPageQuery(),
	}
}

// LoadRecords populates action.Records
func (action *AccountIndexAction) LoadRecords() {
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *AccountIndexAction) LoadPage() {
	action.LoadRecords()
	if action.Err != nil {
		return
	}

	action.Page, action.Err = NewHistoryAccountResourcePage(action.Records, action.Query.PageQuery)
}

// JSON is a method for actions.JSON
func (action *AccountIndexAction) JSON() {
	action.LoadPage()
	if action.Err != nil {
		return
	}
	hal.Render(action.W, action.Page)
}

// SSE is a method for actions.SSE
func (action *AccountIndexAction) SSE(stream sse.Stream) {
	action.LoadRecords()
	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	for _, record := range action.Records[stream.SentCount():] {
		stream.Send(sse.Event{
			ID:   record.PagingToken(),
			Data: NewHistoryAccountResource(record),
		})
	}

	if stream.SentCount() >= int(action.Query.Limit) {
		stream.Done()
	}
}

// AccountShowAction renders a account summary found by its address.
type AccountShowAction struct {
	Action
	Query  db.AccountByAddressQuery
	Record db.AccountRecord
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
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Get(action.Ctx, action.Query, &action.Record)
}

// JSON is a method for actions.JSON
func (action *AccountShowAction) JSON() {
	action.LoadRecord()
	if action.Err != nil {
		return
	}

	hal.Render(action.W, NewAccountResource(action.Record))
}

// SSE is a method for actions.SSE
func (action *AccountShowAction) SSE(stream sse.Stream) {
	action.LoadRecord()
	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	stream.Send(sse.Event{
		Data: NewAccountResource(action.Record),
	})

	if stream.SentCount() >= 10 {
		stream.Done()
	}
}
