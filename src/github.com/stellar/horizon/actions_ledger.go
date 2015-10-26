package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
)

// This file contains the actions:
//
// LedgerIndexAction: pages of ledgers
// LedgerShowAction: single ledger by sequence

// LedgerIndexAction renders a page of ledger resources, identified by
// a normal page query.
type LedgerIndexAction struct {
	Action
	Query   db.LedgerPageQuery
	Records []db.LedgerRecord
	Page    hal.Page
}

// LoadQuery sets action.Query from the request params
func (action *LedgerIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.LedgerPageQuery{
		SqlQuery:  action.App.HistoryQuery(),
		PageQuery: action.GetPageQuery(),
	}
}

// LoadRecords populates action.Records
func (action *LedgerIndexAction) LoadRecords() {
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *LedgerIndexAction) LoadPage() {
	action.LoadRecords()
	if action.Err != nil {
		return
	}

	action.Page, action.Err = NewLedgerResourcePage(action.Records, action.Query.PageQuery)
}

// JSON is a method for actions.JSON
func (action *LedgerIndexAction) JSON() {
	action.LoadPage()
	if action.Err != nil {
		return
	}
	hal.Render(action.W, action.Page)
}

// SSE is a method for actions.SSE
func (action *LedgerIndexAction) SSE(stream sse.Stream) {
	action.LoadRecords()

	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	records := action.Records[stream.SentCount():]

	for _, record := range records {
		stream.Send(sse.Event{
			ID:   record.PagingToken(),
			Data: NewLedgerResource(record),
		})
	}

	if stream.SentCount() >= int(action.Query.Limit) {
		stream.Done()
	}
}

// LedgerShowAction renders a ledger found by its sequence number.
type LedgerShowAction struct {
	Action
	Record db.LedgerRecord
}

// Query returns a database query to find a ledger by sequence
func (action *LedgerShowAction) Query() db.LedgerBySequenceQuery {
	return db.LedgerBySequenceQuery{
		SqlQuery: action.App.HistoryQuery(),
		Sequence: action.GetInt32("id"),
	}
}

// JSON is a method for actions.JSON
func (action *LedgerShowAction) JSON() {
	query := action.Query()

	if action.Err != nil {
		return
	}

	action.Err = db.Get(action.Ctx, query, &action.Record)

	if action.Err != nil {
		return
	}

	hal.Render(action.W, NewLedgerResource(action.Record))
}
