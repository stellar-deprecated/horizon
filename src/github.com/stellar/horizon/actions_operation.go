package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
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
	Records []history.Operation
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *OperationIndexAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecords, action.LoadPage)
	action.Do(func() {
		hal.Render(action.W, action.Page)
	})
}

// SSE is a method for actions.SSE
func (action *OperationIndexAction) SSE(stream sse.Stream) {
	action.Setup(action.LoadQuery)
	action.Do(
		action.LoadRecords,
		func() {
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
func (action *OperationIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.OperationPageQuery{
		SqlQuery:        action.App.HorizonQuery(),
		PageQuery:       action.GetPageQuery(),
		AccountAddress:  action.GetString("account_id"),
		LedgerSequence:  action.GetInt32("ledger_id"),
		TransactionHash: action.GetString("tx_id"),
	}
}

// LoadRecords populates action.Records
func (action *OperationIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *OperationIndexAction) LoadPage() {
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

// OperationShowAction renders a ledger found by its sequence number.
type OperationShowAction struct {
	Action
	ID       int64
	Record   history.Operation
	Resource interface{}
}

func (action *OperationShowAction) loadParams() {
	action.ID = action.GetInt64("id")
}

func (action *OperationShowAction) loadRecord() {
	action.Err = action.HistoryQ().OperationByID(&action.Record, action.ID)
}

func (action *OperationShowAction) loadResource() {
	action.Resource, action.Err = resource.NewOperation(action.Ctx, action.Record)
}

// JSON is a method for actions.JSON
func (action *OperationShowAction) JSON() {
	action.Do(action.loadParams, action.loadRecord, action.loadResource)
	action.Do(func() {
		hal.Render(action.W, action.Resource)
	})
}
