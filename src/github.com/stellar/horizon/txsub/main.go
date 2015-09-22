package txsub

import (
	"fmt"
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
	"sync"
	"time"
)

// System represents a completely configured transaction submission system.
// Its methods tie together the various pieces used to reliably submit transactions
// to a stellar-core instance.
type System struct {
	sync.Once
	pending           OpenSubmissionList
	results           ResultProvider
	submitter         Submitter
	networkPassphrase string

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
	ResultByHash(string) (Result, bool)

	// Look up a result by address and sequence number
	ResultByAddressAndSequence(string, uint64) (Result, bool)
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

	// Duration records the time it took to submit a transaction
	// to stellar-core
	Duration time.Duration
}

func (s SubmissionResult) IsBadSeq() (bool, error) {
	if s.Err == nil {
		return false, nil
	}

	fte, ok := s.Err.(*FailedTransactionError)
	if !ok {
		return false, nil
	}

	result, err := fte.Result()
	if err != nil {
		return false, err
	}

	return result.Result.Code == xdr.TransactionResultCodeTxBadSeq, nil
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

func (fte *FailedTransactionError) Result() (result xdr.TransactionResult, err error) {
	err = xdr.SafeUnmarshalBase64(fte.ResultXDR, &result)
	return
}

// Submit submits the provided base64 encoded transaction envelope to the
// network using this submission system.
func (sys *System) Submit(ctx context.Context, env string) (result <-chan Result) {
	sys.init(ctx)
	response := make(chan Result, 1)
	result = response

	// calculate hash of transaction
	info, err := extractEnvelopeInfo(ctx, env, sys.networkPassphrase)
	if err != nil {
		response <- Result{Err: err}
		return
	}

	// check the configured result provider for an existing result
	r, found := sys.results.ResultByHash(info.Hash)

	if found {
		response <- r
		return
	}

	// submit to stellar-core
	sr := sys.submitter.Submit(env)
	sys.Metrics.SubmissionTimer.Update(sr.Duration)

	// if received or duplicate, add to the open submissions list
	if sr.Err == nil {
		sys.Metrics.SuccessfulSubmissionsMeter.Mark(1)
		sys.pending.Add(info.Hash, response)
		return
	}

	sys.Metrics.FailedSubmissionsMeter.Mark(1)

	// any error other than "txBAD_SEQ" is a failure
	isBad, err := sr.IsBadSeq()
	if err != nil {
		response <- Result{Err: err}
		return
	}

	if !isBad {
		response <- Result{Err: sr.Err}
		return
	}

	r, found = sys.results.ResultByAddressAndSequence(info.SourceAddress, info.Sequence)

	// If the found result is the same hash, use it as the result
	if found && r.Hash == info.Hash {
		response <- r
		return
	}

	// finally, return the bad_seq error if the hash is different
	response <- Result{Err: sr.Err}
	return
}

// Ticker triggers the system to update itself with any new data available.
func (sys *System) Tick(ctx context.Context) {
	sys.init(ctx)
	for _, hash := range sys.pending.Pending() {
		r, ok := sys.results.ResultByHash(hash)

		if ok {
			sys.pending.Finish(r)
		}
	}

	stillOpen, err := sys.pending.Clean(1 * time.Minute)
	if err != nil {
		log.WithStack(ctx, err).Error(err)
	}

	sys.Metrics.OpenSubmissionsGauge.Update(int64(stillOpen))
}

func (sys *System) init(ctx context.Context) {
	sys.Do(func() {
		sys.Metrics.FailedSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SuccessfulSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SubmissionTimer = metrics.NewTimer()
		sys.Metrics.OpenSubmissionsGauge = metrics.NewGauge()
	})
}
