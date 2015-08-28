package horizon

import (
	"github.com/stellar/go-horizon/actions"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/sse"
)

// This file contains the actions:
//
// EffectIndexAction: pages of operations

// EffectIndexAction renders a page of effect resources, identified by
// a normal page query and optionally filtered by an account, ledger,
// transaction, or operation.
type EffectIndexAction struct {
	Action
	Query   db.EffectPageQuery
	Records []db.EffectRecord
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *EffectIndexAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecords, action.LoadPage)

	action.Do(func() {
		hal.Render(action.W, action.Page)
	})
}

// SSE is a method for actions.SSE
func (action *EffectIndexAction) SSE(stream sse.Stream) {
	action.LoadRecords()

	if action.Err != nil {
		stream.Err(action.Err)
		return
	}

	records := action.Records[stream.SentCount():]

	for _, record := range records {
		r, err := NewEffectResource(record)

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

// LoadQuery sets action.Query from the request params
func (action *EffectIndexAction) LoadQuery() {
	action.ValidateInt64(actions.ParamCursor)
	action.Query = db.EffectPageQuery{
		SqlQuery:        action.App.HistoryQuery(),
		PageQuery:       action.GetPageQuery(),
		AccountAddress:  action.GetString("account_id"),
		LedgerSequence:  action.GetInt32("ledger_id"),
		TransactionHash: action.GetString("tx_id"),
		OperationID:     action.GetInt64("op_id"),
	}
}

// LoadRecords populates action.Records
func (action *EffectIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *EffectIndexAction) LoadPage() {
	action.Page, action.Err = NewEffectResourcePage(action.Records, action.Query.PageQuery, action.Path())
}
