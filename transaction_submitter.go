package horizon

import (
	"bytes"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/url"
	"time"

	"golang.org/x/net/context"

	"github.com/Sirupsen/logrus"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-horizon/httpx"
	"github.com/stellar/go-horizon/log"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-stellar-base/build"
	"github.com/stellar/go-stellar-base/xdr"
)

// TransactionSubmitter is responsible for submiting transactions to a
// stellar-core process
type TransactionSubmitter struct {
	baseURL         url.URL
	submissionTimer metrics.Timer
}

// Submit submits the provided hex to stellar-core
func (ts *TransactionSubmitter) Submit(ctx context.Context, txHex string) (hash string, err error) {
	submitStart := time.Now()

	// setup internal logger
	entry := log.WithField(ctx, "bytes", len(txHex)/2)
	entry.Info("Starting transaction submission")

	// epilogue
	defer func() {
		duration := time.Since(submitStart)
		status := "success"
		if err != nil {
			status = "failed"
		}

		entry.WithFields(logrus.Fields{
			"duration": duration,
			"status":   status,
		}).Info("Finished transaction submission")

		ts.submissionTimer.Update(duration)
	}()

	// extract the hash as hex
	hash, err = ts.extractHash(txHex)

	if err != nil {
		return
	}

	// if it is already validated, return
	exists, err := ts.hashExists(ctx, hash)

	if err != nil {
		return
	}

	if exists {
		return
	}

	u := ts.baseURL
	u.Path = "/tx"
	u.RawQuery = "blob=" + txHex

	entry.Debugf("request: %s", txHex)

	client := httpx.ClientFromContext(ctx)

	resp, err := client.Get(u.String())

	if err != nil {
		return
	}

	defer resp.Body.Close()
	rawBody, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		return
	}

	entry.Debugf("response: %s", rawBody)

	var sr coreSubmissionResponse
	err = json.Unmarshal(rawBody, &sr)

	if err != nil {
		return
	}

	// HACK: set fields on the response that originate from the request.
	// This allows us to produce richer errors that incorporate request
	// information to make for easier debugging.
	sr.Hash = hash
	sr.Hex = txHex

	// If the response was a PAST_SEQ error, we should check if our hash exists
	// again, because a ledger may have closed since we checked above, and this
	// transaction may have been included within that ledger.
	//
	// If the hash is found, we respond with success
	if sr.IsPastSequenceError() {
		exists, err = ts.hashExists(ctx, hash)

		if err != nil {
			return
		}

		if exists {
			return
		}
	}

	// If the submission is an error, set it and return
	err2 := sr.Error()
	if err2 != nil {
		err = err2
		return
	}

	// if we fall all the way through, this submission was a success,
	// err should be nil, and hash should be populated.
	return
}

func (ts *TransactionSubmitter) extractHash(txHex string) (string, error) {
	if txHex == "" {
		return "", ErrMalformedTransaction{Reason: "empty string", Hex: txHex}
	}

	var txe xdr.TransactionEnvelope
	b, err := hex.DecodeString(txHex)

	if err != nil {
		return "", ErrMalformedTransaction{Reason: "invalid hex", Hex: txHex}
	}

	n, err := xdr.Unmarshal(bytes.NewReader(b), &txe)

	if err != nil {
		return "", ErrMalformedTransaction{
			Reason: fmt.Sprintf("invalid xdr: %s", err.Error()),
			Hex:    txHex,
		}
	}

	if n != len(b) {
		return "", ErrMalformedTransaction{
			Reason: "invalid xdr: leftover bytes",
			Hex:    txHex,
		}
	}

	txb := build.TransactionBuilder{TX: txe.Tx}
	return txb.HashHex()
}

func (ts *TransactionSubmitter) hashExists(ctx context.Context, hash string) (bool, error) {
	//TODO: check history db for hash, short circuit if available
	//TODO: check core db for hash, short circuit if available
	return false, nil
}

// coreSubmissionResponse is the json response from stellar-core
type coreSubmissionResponse struct {
	Status    string `json:"status"`
	ResultXDR string `json:"error"`
	Exception string `json:"exception"`
	Hash      string //HACK: this has to be set explicitly by submit.
	Hex       string //HACK: this has to be set explicitly by submit.
}

func (cs coreSubmissionResponse) Error() error {
	switch {
	case cs.Status == "DUPLICATE":
		return nil
	case cs.Status == "PENDING":
		return nil
	case cs.Status == "ERROR":
		return ErrFailedSubmission{
			Hash:   cs.Hash,
			Result: cs.ResultXDR,
		}
	case cs.Exception != "":
		return ErrMalformedTransaction{
			Reason: cs.Exception,
			Hex:    cs.Hex,
		}
	default:
		return errors.New("Unknown submission response state")
	}
}

func (cs coreSubmissionResponse) IsPastSequenceError() bool {
	return false
}

// ErrMalformedTransaction is the error that occurs when a client submits a
// malformed transaction.  An empty
type ErrMalformedTransaction struct {
	Reason string
	Hex    string
}

func (err ErrMalformedTransaction) Error() string {
	return fmt.Sprintf("Invalid tx hex. reason:%s", err.Reason)
}

// Problem transforms the error into a Problem, suitable for rendering
// to the requesting client.
func (err ErrMalformedTransaction) Problem() problem.P {
	return problem.P{
		Type:   "transaction_malformed",
		Title:  fmt.Sprintf("Malformed Transaction: %s", err.Reason),
		Status: 400,
		Detail: "The submitted transaction was malformed.  A submission to " +
			"the Stellar network was not even attempted.  To resolve, please ensure " +
			"that your transaction is a hex-encoded string that contains an XDR " +
			"TransactionEnvelope struct.",
	}
}

// ErrFailedSubmission is the error that occurs when stellar-core responds with
// an error result
type ErrFailedSubmission struct {
	Hash   string
	Result string
}

func (err ErrFailedSubmission) Error() string {
	return "Transaction failed"
}

// Problem transforms the error into a Problem, suitable for rendering
// to the requesting client.
func (err ErrFailedSubmission) Problem() problem.P {
	return problem.P{
		Type:   "transaction_failed",
		Title:  "Failed Transaction",
		Status: 400,
		Detail: "The submitted transaction failed.",
		Extras: map[string]interface{}{
			"hash":       err.Hash,
			"result_xdr": err.Result,
		},
	}
}
