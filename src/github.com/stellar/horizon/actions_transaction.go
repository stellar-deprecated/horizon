package horizon

import (
	"net/http"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
	"github.com/stellar/horizon/txsub"
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

// LoadQuery sets action.Query from the request params
func (action *TransactionIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.TransactionPageQuery{
		SqlQuery:       action.App.HistoryQuery(),
		PageQuery:      action.GetPageQuery(),
		AccountAddress: action.GetString("account_id"),
		LedgerSequence: action.GetInt32("ledger_id"),
	}
}

// LoadRecords populates action.Records
func (action *TransactionIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *TransactionIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.Transaction
		res.Populate(record)
		action.Page.Add(res)
	}

	action.Page.Host = action.R.Host
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}

// JSON is a method for actions.JSON
func (action *TransactionIndexAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// SSE is a method for actions.SSE
func (action *TransactionIndexAction) SSE(stream sse.Stream) {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		func() {
			records := action.Records[stream.SentCount():]

			for _, record := range records {
				var res resource.Transaction
				res.Populate(record)
				stream.Send(sse.Event{ID: res.PagingToken(), Data: res})
			}

			if stream.SentCount() >= int(action.Query.Limit) {
				stream.Done()
			}
		},
	)
}

// TransactionShowAction renders a ledger found by its sequence number.
type TransactionShowAction struct {
	Action
	Query    db.TransactionByHashQuery
	Record   db.TransactionRecord
	Resource resource.Transaction
}

func (action *TransactionShowAction) LoadQuery() {
	action.Query = db.TransactionByHashQuery{
		SqlQuery: action.App.HistoryQuery(),
		Hash:     action.GetString("id"),
	}
}

func (action *TransactionShowAction) LoadRecord() {
	action.Err = db.Get(action.Ctx, action.Query, &action.Record)
}

func (action *TransactionShowAction) LoadResource() {
	action.Resource.Populate(action.Record)
}

// JSON is a method for actions.JSON
func (action *TransactionShowAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecord,
		action.LoadResource,
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
		action.LoadTX,
		action.LoadResult,
		action.LoadResource,

		func() {
			hal.Render(action.W, action.Resource)
		})
}

func (action *TransactionCreateAction) LoadTX() {
	action.ValidateBodyType()
	action.TX = action.GetString("tx")
}

func (action *TransactionCreateAction) LoadResult() {
	submission := action.App.submitter.Submit(action.Ctx, action.TX)

	select {
	case result := <-submission:
		action.Result = result
	case <-action.Ctx.Done():
		action.Err = &problem.Timeout
	}
}

func (action *TransactionCreateAction) LoadResource() {
	if action.Result.Err == nil {
		action.Resource.Populate(action.Result)
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
		rcr.Populate(err)

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
