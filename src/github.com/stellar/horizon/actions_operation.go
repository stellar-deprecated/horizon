package horizon

import (
	"github.com/stellar/horizon/actions"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
)

// This file contains the actions:
//
// OperationIndexAction: pages of operations
// OperationShowAction: single operation by id

// OperationIndexAction renders a page of operations resources, identified by
// a normal page query and optionally filtered by an account, ledger, or
// transaction.
type OperationIndexAction struct {
	Action
	Query   db.OperationPageQuery
	Records []db.OperationRecord
	Page    hal.Page
}

// LoadQuery sets action.Query from the request params
func (action *OperationIndexAction) LoadQuery() {
	action.ValidateInt64(actions.ParamCursor)
	action.Query = db.OperationPageQuery{
		SqlQuery:        action.App.HistoryQuery(),
		PageQuery:       action.GetPageQuery(),
		AccountAddress:  action.GetString("account_id"),
		LedgerSequence:  action.GetInt32("ledger_id"),
		TransactionHash: action.GetString("tx_id"),
	}
}

// LoadRecords populates action.Records
func (action *OperationIndexAction) LoadRecords() {
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *OperationIndexAction) LoadPage() {
	action.LoadRecords()
	if action.Err != nil {
		return
	}

	action.Page, action.Err = NewOperationResourcePage(action.Records, action.Query.PageQuery, action.Path())
}

// JSON is a method for actions.JSON
func (action *OperationIndexAction) JSON() {
	action.LoadPage()
	if action.Err != nil {
		return
	}
	hal.Render(action.W, action.Page)
}

// SSE is a method for actions.SSE
func (action *OperationIndexAction) SSE(stream sse.Stream) {
	action.LoadRecords()

	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	records := action.Records[stream.SentCount():]

	for _, record := range records {
		r, err := NewOperationResource(record)

		if err != nil {
			stream.Err(action.Err)
			return
		}

		stream.Send(sse.Event{
			ID:   record.PagingToken(),
			Data: r,
		})
	}

	if stream.SentCount() >= int(action.Query.Limit) {
		stream.Done()
	}
}

// OperationShowAction renders a ledger found by its sequence number.
type OperationShowAction struct {
	Action
	Record db.OperationRecord
}

// Query returns a database query to find a ledger by sequence
func (action *OperationShowAction) Query() db.OperationByIdQuery {
	return db.OperationByIdQuery{
		SqlQuery: action.App.HistoryQuery(),
		Id:       action.GetInt64("id"),
	}
}

// JSON is a method for actions.JSON
func (action *OperationShowAction) JSON() {
	query := action.Query()
	if action.Err != nil {
		return
	}

	action.Err = db.Get(action.Ctx, query, &action.Record)
	if action.Err != nil {
		return
	}

	r, err := NewOperationResource(action.Record)
	if err != nil {
		return
	}

	hal.Render(action.W, r)
}
