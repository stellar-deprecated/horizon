package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/txsub"
	"net/http"
)

type ResultResource struct {
	txsub.Result
}

func (res *ResultResource) Error() error {
	switch err := res.Err.(type) {
	case *txsub.FailedTransactionError:
		// TODO: Fill detail
		return &problem.P{
			Type:   "transaction_failed",
			Title:  "Transaction Failed",
			Status: http.StatusBadRequest,
			Detail: "TODO",
			Extras: map[string]interface{}{
				"envelope_xdr": res.EnvelopeXDR,
				"result_xdr":   err.ResultXDR,
			},
		}
	case *txsub.MalformedTransactionError:
		return &problem.P{
			Type:   "transaction_malformed",
			Title:  "Transaction Malformed",
			Status: http.StatusBadRequest,
			Detail: "TODO",
			Extras: map[string]interface{}{
				"envelope_xdr": err.EnvelopeXDR,
			},
		}
	default:
		return err
	}
}

func (res *ResultResource) IsSuccess() bool {
	return res.Err == nil
}

func (res *ResultResource) Success() interface{} {
	return struct {
		Links  halgo.Links
		Hash   string `json:"hash"`
		Ledger int32  `json:"ledger"`
		Env    string `json:"envelope_xdr"`
		Result string `json:"result_xdr"`
		Meta   string `json:"result_meta_xdr"`
		// TODO: add result code details
	}{
		halgo.Links{}.Link("transaction", "/transactions/%s", res.Hash),
		res.Hash,
		res.LedgerSequence,
		res.EnvelopeXDR,
		res.ResultXDR,
		res.ResultMetaXDR,
	}

}
