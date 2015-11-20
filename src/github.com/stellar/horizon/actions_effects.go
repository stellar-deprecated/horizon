package horizon

import (
	"errors"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
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
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		func() {
			stream.SetLimit(int(action.Query.Limit))
			records := action.Records[stream.SentCount():]

			for _, record := range records {
				res, err := resource.NewEffect(action.Ctx, record)

				if err != nil {
					stream.Err(action.Err)
					return
				}

				stream.Send(sse.Event{
					ID:   res.PagingToken(),
					Data: res,
				})
			}
		},
	)
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
	for _, record := range action.Records {
		var res hal.Pageable
		res, action.Err = resource.NewEffect(action.Ctx, record)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}

	action.Page.Host = action.R.Host
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}

// ValidateCursor ensures that the provided cursor parameter is of the form
// OPERATIONID-INDEX (such as 1234-56) or is the special value "now" that
// represents the the cursor directly after the last closed ledger
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
