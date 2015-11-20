package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

type PaymentsIndexAction struct {
	Action
	Query   db.OperationPageQuery
	Records []db.OperationRecord
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *PaymentsIndexAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecords, action.LoadPage)
	action.Do(func() {
		hal.Render(action.W, action.Page)
	})
}

// SSE is a method for actions.SSE
func (action *PaymentsIndexAction) SSE(stream sse.Stream) {
	action.Do(action.LoadQuery, action.LoadRecords)
	action.Do(func() {
		stream.SetLimit(int(action.Query.Limit))
		records := action.Records[stream.SentCount():]

		for _, record := range records {
			res, err := resource.NewOperation(action.Ctx, record)

			if err != nil {
				stream.Err(action.Err)
				return
			}

			stream.Send(sse.Event{
				ID:   res.PagingToken(),
				Data: res,
			})
		}
	})

}

// LoadQuery sets action.Query from the request params
func (action *PaymentsIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.OperationPageQuery{
		SqlQuery:        action.App.HistoryQuery(),
		PageQuery:       action.GetPageQuery(),
		AccountAddress:  action.GetString("account_id"),
		LedgerSequence:  action.GetInt32("ledger_id"),
		TransactionHash: action.GetString("tx_id"),
		TypeFilter:      db.PaymentTypeFilter,
	}
}

// LoadRecords populates action.Records
func (action *PaymentsIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *PaymentsIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res hal.Pageable
		res, action.Err = resource.NewOperation(action.Ctx, record)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}
