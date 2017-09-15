package txsub

import (
	"sync"
	"time"

	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/pkg/log"
	"github.com/stellar/horizon/pkg/txsub/sequence"
	"golang.org/x/net/context"
)

// System represents a completely configured transaction submission system.
// Its methods tie together the various pieces used to reliably submit transactions
// to a stellar-core instance.
type System struct {
	initializer sync.Once

	Pending           OpenSubmissionList
	Results           ResultProvider
	Sequences         SequenceProvider
	Submitter         Submitter
	SubmissionQueue   *sequence.Manager
	NetworkPassphrase string
	SubmissionTimeout time.Duration

	Metrics struct {
		// SubmissionTimer exposes timing metrics about the rate and latency of
		// submissions to stellar-core
		SubmissionTimer metrics.Timer

		// BufferedSubmissionGauge tracks the count of submissions buffered
		// behind this system's SubmissionQueue
		BufferedSubmissionsGauge metrics.Gauge

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

// Submit submits the provided base64 encoded transaction envelope to the
// network using this submission system.
func (sys *System) Submit(ctx context.Context, env string) (result <-chan Result) {
	sys.Init()
	response := make(chan Result, 1)
	result = response

	// calculate hash of transaction
	info, err := extractEnvelopeInfo(ctx, env, sys.NetworkPassphrase)
	if err != nil {
		sys.finish(response, Result{Err: err, EnvelopeXDR: env})
		return
	}

	// check the configured result provider for an existing result
	r := sys.Results.ResultByHash(ctx, info.Hash)

	if r.Err != ErrNoResults {
		sys.finish(response, r)
		return
	}

	curSeq, err := sys.Sequences.Get([]string{info.SourceAddress})
	if err != nil {
		sys.finish(response, Result{Err: err, EnvelopeXDR: env})
		return
	}

	// If account's sequence cannot be found, abort with tx_NO_ACCOUNT
	// error code
	if _, ok := curSeq[info.SourceAddress]; !ok {
		sys.finish(response, Result{Err: ErrNoAccount, EnvelopeXDR: env})
		return
	}

	// queue the submission and get the channel that will emit when
	// submission is valid
	seq := sys.SubmissionQueue.Push(info.SourceAddress, info.Sequence)

	// update the submission queue with the source accounts current sequence value
	// which will cause the channel returned by Push() to emit if possible.
	sys.SubmissionQueue.Update(curSeq)

	select {
	case err := <-seq:
		if err == sequence.ErrBadSequence {
			// convert the internal only ErrBadSequence into the FailedTransactionError
			err = ErrBadSequence
		}

		if err != nil {
			sys.finish(response, Result{Err: err, EnvelopeXDR: env})
			return
		}

		sr := sys.submitOnce(ctx, env)

		// if submission succeeded
		if sr.Err == nil {
			// add transactions to open list
			sys.Pending.Add(ctx, info.Hash, response)
			// update the submission queue, allowing the next submission to proceed
			sys.SubmissionQueue.Update(map[string]uint64{info.SourceAddress: info.Sequence})
			return
		}

		// any error other than "txBAD_SEQ" is a failure
		isBad, err := sr.IsBadSeq()
		if err != nil {
			sys.finish(response, Result{Err: err, EnvelopeXDR: env})
			return
		}

		if !isBad {
			sys.finish(response, Result{Err: sr.Err, EnvelopeXDR: env})
			return
		}

		// If error is txBAD_SEQ, check for the result again
		r = sys.Results.ResultByHash(ctx, info.Hash)

		if r.Err == nil {
			// If the found use it as the result
			sys.finish(response, r)
		} else {
			// finally, return the bad_seq error if no result was found on 2nd attempt
			sys.finish(response, Result{Err: sr.Err, EnvelopeXDR: env})
		}

	case <-ctx.Done():
		sys.finish(response, Result{Err: ErrCanceled, EnvelopeXDR: env})
	}

	return
}

// Submit submits the provided base64 encoded transaction envelope to the
// network using this submission system.
func (sys *System) submitOnce(ctx context.Context, env string) SubmissionResult {
	// submit to stellar-core
	sr := sys.Submitter.Submit(ctx, env)
	sys.Metrics.SubmissionTimer.Update(sr.Duration)

	// if received or duplicate, add to the open submissions list
	if sr.Err == nil {
		sys.Metrics.SuccessfulSubmissionsMeter.Mark(1)
	} else {
		sys.Metrics.FailedSubmissionsMeter.Mark(1)
	}

	return sr
}

// Tick triggers the system to update itself with any new data available.
func (sys *System) Tick(ctx context.Context) {
	sys.Init()
	logger := log.Ctx(ctx)

	logger.
		WithField("queued", sys.SubmissionQueue.String()).
		Debug("ticking txsub system")

	addys := sys.SubmissionQueue.Addresses()
	if len(addys) > 0 {
		curSeq, err := sys.Sequences.Get(addys)
		if err != nil {
			logger.WithStack(err).Error(err)
		} else {
			sys.SubmissionQueue.Update(curSeq)
		}
	}

	for _, hash := range sys.Pending.Pending(ctx) {
		r := sys.Results.ResultByHash(ctx, hash)

		if r.Err == nil {
			logger.WithField("hash", hash).Debug("finishing open submission")
			sys.Pending.Finish(ctx, r)
			continue
		}

		_, ok := r.Err.(*FailedTransactionError)

		if ok {
			logger.WithField("hash", hash).Debug("finishing open submission")
			sys.Pending.Finish(ctx, r)
			continue
		}

		if r.Err != ErrNoResults {
			logger.WithStack(r.Err).Error(r.Err)
		}
	}

	stillOpen, err := sys.Pending.Clean(ctx, sys.SubmissionTimeout)
	if err != nil {
		logger.WithStack(err).Error(err)
	}

	sys.Metrics.OpenSubmissionsGauge.Update(int64(stillOpen))
	sys.Metrics.BufferedSubmissionsGauge.Update(int64(sys.SubmissionQueue.Size()))
}

// Init initializes `sys`
func (sys *System) Init() {
	sys.initializer.Do(func() {
		sys.Metrics.FailedSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SuccessfulSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SubmissionTimer = metrics.NewTimer()
		sys.Metrics.OpenSubmissionsGauge = metrics.NewGauge()
		sys.Metrics.BufferedSubmissionsGauge = metrics.NewGauge()

		if sys.SubmissionTimeout == 0 {
			sys.SubmissionTimeout = 1 * time.Minute
		}
	})
}

func (sys *System) finish(response chan<- Result, r Result) {
	response <- r
	close(response)
}
