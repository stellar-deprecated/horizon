package txsub

import (
	"errors"
	"golang.org/x/net/context"
	"testing"
	"time"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/build"
	"github.com/stellar/horizon/test"
)

func TestTxsub(t *testing.T) {
	Convey("txsub.System", t, func() {
		ctx := test.Context()
		submitter := &MockSubmitter{}
		results := &MockResultProvider{}

		system := &System{
			Pending:           NewDefaultSubmissionList(),
			Submitter:         submitter,
			Results:           results,
			NetworkPassphrase: build.TestNetwork.Passphrase,
		}

		noResults := Result{Err: ErrNoResults}
		successTx := Result{
			Hash:           "c492d87c4642815dfb3c7dcce01af4effd162b031064098a0d786b6e0a00fd74",
			LedgerSequence: 2,
			EnvelopeXDR:    "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAKZ7IPj/46PuWU6ZOtyMosctNAkXRNX9WCAI5RnfRk+AyxDLoDZP/9l3NvsxQtWj9juQOuoBlFLnWu8intgxQA",
			ResultXDR:      "xJLYfEZCgV37PH3M4Br07/0WKwMQZAmKDXhrbgoA/XQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==",
		}

		badSeq := SubmissionResult{
			Err: &FailedTransactionError{"AAAAAAAAAAD////7AAAAAA=="},
		}

		Convey("Submit", func() {
			Convey("returns the result provided by the ResultProvider", func() {
				results.Results = []Result{successTx}
				r := <-system.Submit(ctx, successTx.EnvelopeXDR)

				So(r.Err, ShouldBeNil)
				So(r.Hash, ShouldEqual, successTx.Hash)
				So(submitter.WasSubmittedTo, ShouldBeFalse)
			})

			Convey("returns the error from submission if no result is found by hash and the submitter returns an error", func() {
				submitter.R.Err = errors.New("busted for some reason")
				r := <-system.Submit(ctx, successTx.EnvelopeXDR)

				So(r.Err, ShouldNotBeNil)
				So(submitter.WasSubmittedTo, ShouldBeTrue)
				So(system.Metrics.SuccessfulSubmissionsMeter.Count(), ShouldEqual, 0)
				So(system.Metrics.FailedSubmissionsMeter.Count(), ShouldEqual, 1)
				So(system.Metrics.SubmissionTimer.Count(), ShouldEqual, 1)
			})

			Convey("if the error is bad_seq and the result at the transaction's sequence number is for the same hash, return result", func() {
				submitter.R = badSeq
				results.Results = []Result{noResults, successTx}

				r := <-system.Submit(ctx, successTx.EnvelopeXDR)

				So(r.Err, ShouldBeNil)
				So(r.Hash, ShouldEqual, successTx.Hash)
				So(submitter.WasSubmittedTo, ShouldBeTrue)
			})

			Convey("if error is bad_seq and no result is found, return error", func() {
				submitter.R = badSeq
				r := <-system.Submit(ctx, successTx.EnvelopeXDR)

				So(r.Err, ShouldNotBeNil)
				So(submitter.WasSubmittedTo, ShouldBeTrue)
			})

			Convey("if no result found and no error submitting, add to open transaction list", func() {
				_ = system.Submit(ctx, successTx.EnvelopeXDR)
				pending := system.Pending.Pending(ctx)
				So(len(pending), ShouldEqual, 1)
				So(pending[0], ShouldEqual, successTx.Hash)
				So(system.Metrics.SuccessfulSubmissionsMeter.Count(), ShouldEqual, 1)
				So(system.Metrics.FailedSubmissionsMeter.Count(), ShouldEqual, 0)
				So(system.Metrics.SubmissionTimer.Count(), ShouldEqual, 1)
			})
		})

		Convey("Tick", func() {

			Convey("no-ops if there are no open submissions", func() {
				system.Tick(ctx)
			})

			Convey("finishes any available transactions", func() {
				l := make(chan Result, 1)
				system.Pending.Add(ctx, successTx.Hash, l)
				system.Tick(ctx)
				So(len(l), ShouldEqual, 0)
				So(len(system.Pending.Pending(ctx)), ShouldEqual, 1)

				results.Results = []Result{successTx}
				system.Tick(ctx)

				So(len(l), ShouldEqual, 1)
				So(len(system.Pending.Pending(ctx)), ShouldEqual, 0)
			})

			Convey("removes old submissions that have timed out", func() {
				l := make(chan Result, 1)
				system.SubmissionTimeout = 100 * time.Millisecond
				system.Pending.Add(ctx, successTx.Hash, l)
				<-time.After(101 * time.Millisecond)
				system.Tick(ctx)

				So(len(system.Pending.Pending(ctx)), ShouldEqual, 0)

				select {
				case _, stillOpen := <-l:
					So(stillOpen, ShouldBeFalse)
				default:
					panic("could not read from listener")
				}

			})
		})

	})
}

type MockSubmitter struct {
	R              SubmissionResult
	WasSubmittedTo bool
}

func (sub *MockSubmitter) Submit(ctx context.Context, env string) SubmissionResult {
	sub.WasSubmittedTo = true
	return sub.R
}

type MockResultProvider struct {
	Results []Result
}

func (results *MockResultProvider) ResultByHash(ctx context.Context, hash string) (r Result) {
	if len(results.Results) > 0 {
		r = results.Results[0]
		results.Results = results.Results[1:]
	} else {
		r = Result{Err: ErrNoResults}
	}

	return
}
