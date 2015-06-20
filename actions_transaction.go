package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/actions"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/sse"
	"github.com/zenazn/goji/web"
)

// This file contains the actions:
//
// TransactionIndexAction: pages of transactions
// TransactionShowAction: single transaction by sequence, by hash or id

// TransactionIndexAction renders a page of ledger resources, identified by
// a normal page query.
type TransactionIndexAction struct {
	Action
	Query   db.TransactionPageQuery
	Records []db.TransactionRecord
	Page    hal.Page
}

// ServeHTTPC is a method for web.Handler
func (action TransactionIndexAction) ServeHTTPC(c web.C, w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(c, w, r)
	ap.Execute(&action)
}

// LoadQuery sets action.Query from the request params
func (action *TransactionIndexAction) LoadQuery() {
	action.ValidateInt64(actions.ParamCursor)
	action.Query = db.TransactionPageQuery{
		SqlQuery:       action.App.HistoryQuery(),
		PageQuery:      action.GetPageQuery(),
		AccountAddress: action.GetString("account_id"),
		LedgerSequence: action.GetInt32("ledger_id"),
	}
}

// LoadRecords populates action.Records
func (action *TransactionIndexAction) LoadRecords() {
	action.LoadQuery()
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *TransactionIndexAction) LoadPage() {
	action.LoadRecords()
	if action.Err != nil {
		return
	}

	action.Page, action.Err = NewTransactionResourcePage(action.Records, action.Query.PageQuery, action.Path())
}

// JSON is a method for actions.JSON
func (action *TransactionIndexAction) JSON() {
	action.LoadPage()
	if action.Err != nil {
		return
	}
	hal.RenderPage(action.W, action.Page)
}

// SSE is a method for actions.SSE
func (action *TransactionIndexAction) SSE(stream sse.Stream) {
	action.LoadRecords()

	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	records := action.Records[stream.SentCount():]

	for _, record := range records {
		stream.Send(sse.Event{
			ID:   record.PagingToken(),
			Data: NewTransactionResource(record),
		})
	}

	if stream.SentCount() >= int(action.Query.Limit) {
		stream.Done()
	}
}

// TransactionShowAction renders a ledger found by its sequence number.
type TransactionShowAction struct {
	Action
	Record db.TransactionRecord
}

// ServeHTTPC is a method for web.Handler
func (action TransactionShowAction) ServeHTTPC(c web.C, w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(c, w, r)
	ap.Execute(&action)
}

// Query returns a database query to find a ledger by sequence
func (action *TransactionShowAction) Query() db.TransactionByHashQuery {
	return db.TransactionByHashQuery{
		SqlQuery: action.App.HistoryQuery(),
		Hash:     action.GetString("id"),
	}
}

// JSON is a method for actions.JSON
func (action *TransactionShowAction) JSON() {
	query := action.Query()

	if action.Err != nil {
		return
	}

	action.Err = db.Get(action.Ctx, query, &action.Record)

	if action.Err != nil {
		return
	}

	hal.Render(action.W, NewTransactionResource(action.Record))
}
