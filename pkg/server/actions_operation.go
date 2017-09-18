package server

import (
	"errors"
	"fmt"

	"github.com/stellar/horizon/pkg/db2"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/ledger"
	"github.com/stellar/horizon/pkg/render/hal"
	"github.com/stellar/horizon/pkg/render/problem"
	"github.com/stellar/horizon/pkg/render/sse"
	"github.com/stellar/horizon/pkg/resource"
	"github.com/stellar/horizon/pkg/toid"
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
	LedgerFilter      int32
	AccountFilter     string
	TransactionFilter string
	PagingParams      db2.PageQuery
	Records           []history.Operation
	Ledgers           history.LedgerCache
	Page              hal.Page
}

// JSON is a method for actions.JSON
func (action *OperationIndexAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.ValidateCursorWithinHistory,
		action.loadRecords,
		action.loadLedgers,
		action.loadPage)
	action.Do(func() {
		hal.Render(action.W, action.Page)
	})
}

// SSE is a method for actions.SSE
func (action *OperationIndexAction) SSE(stream sse.Stream) {
	action.Setup(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.ValidateCursorWithinHistory,
	)
	action.Do(
		action.loadRecords,
		action.loadLedgers,
		func() {
			stream.SetLimit(int(action.PagingParams.Limit))
			records := action.Records[stream.SentCount():]

			for _, record := range records {
				ledger, found := action.Ledgers.Records[record.LedgerSequence()]
				if !found {
					msg := fmt.Sprintf("could not find ledger data for sequence %d", record.LedgerSequence())
					stream.Err(errors.New(msg))
					return
				}

				res, err := resource.NewOperation(action.Ctx, record, ledger)

				if err != nil {
					stream.Err(err)
					return
				}

				stream.Send(sse.Event{
					ID:   res.PagingToken(),
					Data: res,
				})
			}
		})

}

func (action *OperationIndexAction) loadParams() {
	action.ValidateCursorAsDefault()
	action.AccountFilter = action.GetString("account_id")
	action.LedgerFilter = action.GetInt32("ledger_id")
	action.TransactionFilter = action.GetString("tx_id")
	action.PagingParams = action.GetPageQuery()
}

func (action *OperationIndexAction) loadRecords() {
	q := action.HistoryQ()
	ops := q.Operations()

	switch {
	case action.AccountFilter != "":
		ops.ForAccount(action.AccountFilter)
	case action.LedgerFilter > 0:
		ops.ForLedger(action.LedgerFilter)
	case action.TransactionFilter != "":
		ops.ForTransaction(action.TransactionFilter)
	}

	action.Err = ops.Page(action.PagingParams).Select(&action.Records)
}

// loadLedgers populates the ledger cache for this action
func (action *OperationIndexAction) loadLedgers() {
	for _, op := range action.Records {
		action.Ledgers.Queue(op.LedgerSequence())
	}

	action.Err = action.Ledgers.Load(action.HistoryQ())
}

func (action *OperationIndexAction) loadPage() {
	for _, record := range action.Records {

		ledger, found := action.Ledgers.Records[record.LedgerSequence()]
		if !found {
			msg := fmt.Sprintf("could not find ledger data for sequence %d", record.LedgerSequence())
			action.Err = errors.New(msg)
			return
		}

		var res hal.Pageable
		res, action.Err = resource.NewOperation(action.Ctx, record, ledger)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.PagingParams.Limit
	action.Page.Cursor = action.PagingParams.Cursor
	action.Page.Order = action.PagingParams.Order
	action.Page.PopulateLinks()
}

// OperationShowAction renders a ledger found by its sequence number.
type OperationShowAction struct {
	Action
	ID       int64
	Record   history.Operation
	Ledger   history.Ledger
	Resource interface{}
}

func (action *OperationShowAction) loadParams() {
	action.ID = action.GetInt64("id")
}

func (action *OperationShowAction) loadRecord() {
	action.Err = action.HistoryQ().OperationByID(&action.Record, action.ID)
}

func (action *OperationShowAction) loadLedger() {
	action.Err = action.HistoryQ().LedgerBySequence(&action.Ledger, action.Record.LedgerSequence())
}

func (action *OperationShowAction) loadResource() {
	action.Resource, action.Err = resource.NewOperation(action.Ctx, action.Record, action.Ledger)
}

// JSON is a method for actions.JSON
func (action *OperationShowAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.verifyWithinHistory,
		action.loadRecord,
		action.loadLedger,
		action.loadResource,
	)
	action.Do(func() {
		hal.Render(action.W, action.Resource)
	})
}

func (action *OperationShowAction) verifyWithinHistory() {
	parsed := toid.Parse(action.ID)
	if parsed.LedgerSequence < ledger.CurrentState().HistoryElder {
		action.Err = &problem.BeforeHistory
	}
}
