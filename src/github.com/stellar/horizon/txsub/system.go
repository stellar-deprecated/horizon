package txsub

import (
	"github.com/rcrowley/go-metrics"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
	"sync"
	"time"
)

// System represents a completely configured transaction submission system.
// Its methods tie together the various pieces used to reliably submit transactions
// to a stellar-core instance.
type System struct {
	initializer sync.Once

	Pending           OpenSubmissionList
	Results           ResultProvider
	Submitter         Submitter
	NetworkPassphrase string
	SubmissionTimeout time.Duration

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

// Submit submits the provided base64 encoded transaction envelope to the
// network using this submission system.
func (sys *System) Submit(ctx context.Context, env string) (result <-chan Result) {
	sys.Init(ctx)
	response := make(chan Result, 1)
	result = response

	// calculate hash of transaction
	info, err := extractEnvelopeInfo(ctx, env, sys.NetworkPassphrase)
	if err != nil {
		response <- Result{Err: err, EnvelopeXDR: env}
		return
	}

	// check the configured result provider for an existing result
	r := sys.Results.ResultByHash(ctx, info.Hash)

	if r.Err != ErrNoResults {
		response <- r
		return
	}

	// submit to stellar-core
	sr := sys.Submitter.Submit(ctx, env)
	sys.Metrics.SubmissionTimer.Update(sr.Duration)

	// if received or duplicate, add to the open submissions list
	if sr.Err == nil {
		sys.Metrics.SuccessfulSubmissionsMeter.Mark(1)
		sys.Pending.Add(ctx, info.Hash, response)
		return
	}

	sys.Metrics.FailedSubmissionsMeter.Mark(1)

	// any error other than "txBAD_SEQ" is a failure
	isBad, err := sr.IsBadSeq()
	if err != nil {
		response <- Result{Err: err, EnvelopeXDR: env}
		return
	}

	if !isBad {
		response <- Result{Err: sr.Err, EnvelopeXDR: env}
		return
	}

	// If error is txBAD_SEQ, check for the result again
	r = sys.Results.ResultByHash(ctx, info.Hash)

	if r.Err == nil {
		// If the found use it as the result
		response <- r
	} else {
		// finally, return the bad_seq error if no result was found on 2nd attempt
		response <- Result{Err: sr.Err, EnvelopeXDR: env}
	}

	return
}

// Ticker triggers the system to update itself with any new data available.
func (sys *System) Tick(ctx context.Context) {
	sys.Init(ctx)

	log.Debugln(ctx, "ticking txsub system")
	for _, hash := range sys.Pending.Pending(ctx) {
		r := sys.Results.ResultByHash(ctx, hash)

		if r.Err == nil {
			log.WithField(ctx, "hash", hash).Debug("finishing open submission")
			sys.Pending.Finish(ctx, r)
			continue
		}

		_, ok := r.Err.(*FailedTransactionError)

		if ok {
			log.WithField(ctx, "hash", hash).Debug("finishing open submission")
			sys.Pending.Finish(ctx, r)
			continue
		}

		if r.Err != ErrNoResults {
			log.WithStack(ctx, r.Err).Error(r.Err)
		}
	}

	stillOpen, err := sys.Pending.Clean(ctx, sys.SubmissionTimeout)
	if err != nil {
		log.WithStack(ctx, err).Error(err)
	}

	sys.Metrics.OpenSubmissionsGauge.Update(int64(stillOpen))
}

func (sys *System) Init(ctx context.Context) {
	sys.initializer.Do(func() {
		sys.Metrics.FailedSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SuccessfulSubmissionsMeter = metrics.NewMeter()
		sys.Metrics.SubmissionTimer = metrics.NewTimer()
		sys.Metrics.OpenSubmissionsGauge = metrics.NewGauge()

		if sys.SubmissionTimeout == 0 {
			sys.SubmissionTimeout = 1 * time.Minute
		}
	})
}
