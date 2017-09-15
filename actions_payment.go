package horizon

import (
	"errors"
	"fmt"

	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// PaymentsIndexAction returns a paged slice of payments based upon the provided
// filters
type PaymentsIndexAction struct {
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
func (action *PaymentsIndexAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.ValidateCursorWithinHistory,
		action.loadRecords,
		action.loadLedgers,
		action.loadPage,
	)
	action.Do(func() {
		hal.Render(action.W, action.Page)
	})
}

// SSE is a method for actions.SSE
func (action *PaymentsIndexAction) SSE(stream sse.Stream) {
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

func (action *PaymentsIndexAction) loadParams() {
	action.ValidateCursorAsDefault()
	action.AccountFilter = action.GetString("account_id")
	action.LedgerFilter = action.GetInt32("ledger_id")
	action.TransactionFilter = action.GetString("tx_id")
	action.PagingParams = action.GetPageQuery()
}

func (action *PaymentsIndexAction) loadRecords() {
	q := action.HistoryQ()
	ops := q.Operations().OnlyPayments()

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
func (action *PaymentsIndexAction) loadLedgers() {
	for _, op := range action.Records {
		action.Ledgers.Queue(op.LedgerSequence())
	}

	action.Err = action.Ledgers.Load(action.HistoryQ())
}

func (action *PaymentsIndexAction) loadPage() {
	for _, record := range action.Records {
		var res hal.Pageable

		ledger, found := action.Ledgers.Records[record.LedgerSequence()]
		if !found {
			msg := fmt.Sprintf("could not find ledger data for sequence %d", record.LedgerSequence())
			action.Err = errors.New(msg)
			return
		}

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
