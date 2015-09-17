package txsub

import (
	"fmt"
	"github.com/rcrowley/go-metrics"
	"golang.org/x/net/context"
	"time"
)

// System represents a completely configured transaction submission system.
// Its methods tie together the various pieces used to reliably submit transactions
// to a stellar-core instance.
type System struct {
	OpenSubmissionList
	ResultProvider
	Submitter

	Metrics struct {
		// SubmissionTimer exposes timing metrics about the rate and latency of
		// submissions to stellar-core
		SubmissionTimer metrics.Timer

		// OpenSubmissionsGauge tracks the count of "open" submissions (i.e.
		// submissions whose transactions haven't been confirmed successful or failed
		OpenSubmissionsGauge metrics.Gauge

		// FailedSubmissionsMeter tracks the rate of failed transactions that have
		// been submitted to this process
		FailedSubmissionsMeter metrics.Meter

		// SuccessfulSubmissionsMeter tracks the rate of successful transactions that
		// have been submitted to this process
		SuccessfulSubmissionsMeter metrics.Meter
	}
}

// ResultProvider represents an abstract store that can lookup Result objects
// by transaction hash or by [address,sequence] pairs.  A ResultProvider is
// used within the transaction submission system to decide whether a submission should
// be submitted to the backing stellar-core process, as well as looking up the status
// of each transaction in the open submission list at each tick (i.e. ledger close)
type ResultProvider interface {
	// Look up a result by transaction hash
	ResultByHash(string) Result

	// Look up a result by address and sequence number
	ResultByAddressAndSequence(string, int64) Result
}

// Listener represents some client who is interested in retrieving the result
// of a specific transaction.
type Listener chan<- Result

// OpenSubmissionList represents the structure that tracks pending transactions
// and forwards Result structs on to listeners as they become available.
//
// NOTE:  An implementation of this interface will be called from multiple go-routines
// concurrently.
//
// NOTE:  A Listener must be a buffered channel.  A panic will trigger if you
// provide an unbuffered channel
type OpenSubmissionList interface {
	// Add registers the provided listener as interested in being notified when a
	// result is available for the provided transaction hash.
	Add(string, Listener) error

	// Finish forwards the provided result on to any listeners and cleans up any
	// resources associated with the transaction that this result is for
	Finish(Result) error

	// Clean removes any open submissions over the provided age.
	Clean(time.Duration) (int, error)

	// Pending return a list of transaction hashes that have at least one
	// listener registered to them in this list.
	Pending() []string
}

// Submitter represents the low-level "submit a transaction to stellar-core"
// provider.
type Submitter interface {
	// Submit sends the provided transaction envelope to stellar-core
	Submit(string) SubmissionResult
}

// Result represents the response from a ResultProvider.  Given no
// Err is set, the rest of the struct should be populated appropriately.
type Result struct {
	// Any error that occurred during the retrieval of this result
	Err error

	// The transaction hash to which this result corresponds
	Hash string

	// The ledger sequence in which the transaction this result represents was
	// applied
	LedgerSequence int32

	// The base64-encoded TransactionEnvelope for the transaction this result
	// corresponds to
	EnvelopeXDR string

	// The base64-encoded TransactionResult for the transaction this result
	// corresponds to
	ResultXDR string
}

// SubmissionResult gets returned in response to a call to Submitter.Submit.
// It represents a single discrete submission of a transaction envelope to
// the stellar network.
type SubmissionResult struct {
	// Any error that occurred during the attempted submission.  A nil value
	// indicates that the submission will or already is being considered for
	// inclusion in the ledger (i.e. A successful submission).
	Err error

	Duration time.Duration
}

// FailedTransactionError represent an error that occurred because
// stellar-core rejected the transaction.  ResultXDR is a base64
// encoded TransactionResult struct
type FailedTransactionError struct {
	ResultXDR string
}

func (err *FailedTransactionError) Error() string {
	return fmt.Sprintf("tx failed: %s", err.ResultXDR)
}

// Submit submits the provided base64 encoded transaction envelope to the
// network using this submission system.
func (sys *System) Submit(ctx context.Context, env string) (result <-chan Result) {
	response := make(chan Result, 1)
	result = response

	// calculate hash of transaction
	hash, err := hashForEnvelope(ctx, env)
	if err != nil {
		response <- Result{Err: err}
		return
	}

	_ = hash

	// check the configured result provider for an existing result
	//TODO

	// if result is available, return it
	// if not, continue
	// TODO

	// submit to stellar-core
	// TODO

	// if received or duplicate, add to the open submissions list
	// if error is txBAD_SEQ, consult result provider using address and sequence
	//   if the result _is not_ for this envelope, return the error
	//   if the result _is_ for this envelope return the result
	//   if no result is found, add to the open submissions list
	//TODO

	return
}

// Ticker triggers the system to update itself with any new data available.
func (sys *System) Tick(ctx context.Context) {
	// Load the list of open submission hashes
	// For each, check for a result
	//	If a result is found, finish the submission using the result
	// Trigger a Clean() on the submission list
	// Update metrics
}
