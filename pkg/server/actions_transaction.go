package server

import (
	"net/http"

	"github.com/stellar/horizon/pkg/db2"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/render/hal"
	"github.com/stellar/horizon/pkg/render/problem"
	"github.com/stellar/horizon/pkg/render/sse"
	"github.com/stellar/horizon/pkg/resource"
	"github.com/stellar/horizon/pkg/txsub"
)

// This file contains the actions:
//
// TransactionIndexAction: pages of transactions
// TransactionShowAction: single transaction by sequence, by hash or id

// TransactionIndexAction renders a page of ledger resources, identified by
// a normal page query.
type TransactionIndexAction struct {
	Action
	LedgerFilter  int32
	AccountFilter string
	PagingParams  db2.PageQuery
	Records       []history.Transaction
	Page          hal.Page
}

// JSON is a method for actions.JSON
func (action *TransactionIndexAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.ValidateCursorWithinHistory,
		action.loadRecords,
		action.loadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// SSE is a method for actions.SSE
func (action *TransactionIndexAction) SSE(stream sse.Stream) {
	action.Setup(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.ValidateCursorWithinHistory,
	)
	action.Do(
		action.loadRecords,
		func() {
			stream.SetLimit(int(action.PagingParams.Limit))
			records := action.Records[stream.SentCount():]

			for _, record := range records {
				var res resource.Transaction
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: res.PagingToken(), Data: res})
			}
		},
	)
}

func (action *TransactionIndexAction) loadParams() {
	action.ValidateCursorAsDefault()
	action.AccountFilter = action.GetString("account_id")
	action.LedgerFilter = action.GetInt32("ledger_id")
	action.PagingParams = action.GetPageQuery()
}

func (action *TransactionIndexAction) loadRecords() {
	q := action.HistoryQ()
	txs := q.Transactions()

	switch {
	case action.AccountFilter != "":
		txs.ForAccount(action.AccountFilter)
	case action.LedgerFilter > 0:
		txs.ForLedger(action.LedgerFilter)
	}

	action.Err = txs.Page(action.PagingParams).Select(&action.Records)
}

func (action *TransactionIndexAction) loadPage() {
	for _, record := range action.Records {
		var res resource.Transaction
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.PagingParams.Limit
	action.Page.Cursor = action.PagingParams.Cursor
	action.Page.Order = action.PagingParams.Order
	action.Page.PopulateLinks()
}

// TransactionShowAction renders a ledger found by its sequence number.
type TransactionShowAction struct {
	Action
	Hash     string
	Record   history.Transaction
	Resource resource.Transaction
}

func (action *TransactionShowAction) loadParams() {
	action.Hash = action.GetString("id")
}

func (action *TransactionShowAction) loadRecord() {
	action.Err = action.HistoryQ().TransactionByHash(&action.Record, action.Hash)
}

func (action *TransactionShowAction) loadResource() {
	action.Resource.Populate(action.Ctx, action.Record)
}

// JSON is a method for actions.JSON
func (action *TransactionShowAction) JSON() {
	action.Do(
		action.EnsureHistoryFreshness,
		action.loadParams,
		action.loadRecord,
		action.loadResource,
		func() { hal.Render(action.W, action.Resource) },
	)
}

// TransactionCreateAction submits a transaction to the stellar-core network
// on behalf of the requesting client.
type TransactionCreateAction struct {
	Action
	TX       string
	Result   txsub.Result
	Resource resource.TransactionSuccess
}

// JSON format action handler
func (action *TransactionCreateAction) JSON() {
	action.Do(
		action.loadTX,
		action.loadResult,
		action.loadResource,

		func() {
			hal.Render(action.W, action.Resource)
		})
}

func (action *TransactionCreateAction) loadTX() {
	action.ValidateBodyType()
	action.TX = action.GetString("tx")
}

func (action *TransactionCreateAction) loadResult() {
	submission := action.App.submitter.Submit(action.Ctx, action.TX)

	select {
	case result := <-submission:
		action.Result = result
	case <-action.Ctx.Done():
		action.Err = &problem.Timeout
	}
}

func (action *TransactionCreateAction) loadResource() {
	if action.Result.Err == nil {
		action.Resource.Populate(action.Ctx, action.Result)
		return
	}

	if action.Result.Err == txsub.ErrTimeout {
		action.Err = &problem.Timeout
		return
	}

	if action.Result.Err == txsub.ErrCanceled {
		action.Err = &problem.Timeout
		return
	}

	switch err := action.Result.Err.(type) {
	case *txsub.FailedTransactionError:
		rcr := resource.TransactionResultCodes{}
		rcr.Populate(action.Ctx, err)

		action.Err = &problem.P{
			Type:   "transaction_failed",
			Title:  "Transaction Failed",
			Status: http.StatusBadRequest,
			Detail: "The transaction failed when submitted to the stellar network. " +
				"The `extras.result_codes` field on this response contains further " +
				"details.  Descriptions of each code can be found at: " +
				"https://www.stellar.org/developers/learn/concepts/list-of-operations.html",
			Extras: map[string]interface{}{
				"envelope_xdr": action.Result.EnvelopeXDR,
				"result_xdr":   err.ResultXDR,
				"result_codes": rcr,
			},
		}
	case *txsub.MalformedTransactionError:
		action.Err = &problem.P{
			Type:   "transaction_malformed",
			Title:  "Transaction Malformed",
			Status: http.StatusBadRequest,
			Detail: "Horizon could not decode the transaction envelope in this " +
				"request. A transaction should be an XDR TransactionEnvelope struct " +
				"encoded using base64.  The envelope read from this request is " +
				"echoed in the `extras.envelope_xdr` field of this response for your " +
				"convenience.",
			Extras: map[string]interface{}{
				"envelope_xdr": err.EnvelopeXDR,
			},
		}
	default:
		action.Err = err
	}
}
