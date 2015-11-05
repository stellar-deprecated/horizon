package horizon

import (
	"errors"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"regexp"
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
	action.Do(action.LoadQuery, action.LoadRecords)
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
	action.ValidateCursor()
	action.Query = db.EffectPageQuery{
		SqlQuery:  action.App.HistoryQuery(),
		PageQuery: action.GetPageQuery(),
	}

	if address := action.GetString("account_id"); address != "" {
		action.Query.Filter = &db.EffectAccountFilter{action.Query.SqlQuery, address}
		return
	}

	if seq := action.GetInt32("ledger_id"); seq != 0 {
		action.Query.Filter = &db.EffectLedgerFilter{seq}
		return
	}

	if tx := action.GetString("tx_id"); tx != "" {
		action.Query.Filter = &db.EffectTransactionFilter{action.Query.SqlQuery, tx}
		return
	}

	if op := action.GetInt64("op_id"); op != 0 {
		action.Query.Filter = &db.EffectOperationFilter{op}
		return
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

func (action *EffectIndexAction) ValidateCursor() {
	c := action.GetString("cursor")

	if c == "" {
		return
	}

	ok, err := regexp.MatchString("now|\\d+(-\\d+)?", c)
	if err != nil {
		action.Err = err
		return
	}

	if !ok {
		action.SetInvalidField("cursor", errors.New("invalid format"))
		return
	}

	return
}
