package txsub

import (
	"errors"
	"testing"
	"time"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go/build"
	"github.com/stellar/horizon/pkg/test"
	"github.com/stellar/horizon/pkg/txsub/sequence"
)

func TestTxsub(t *testing.T) {
	Convey("txsub.System", t, func() {
		ctx := test.Context()
		submitter := &MockSubmitter{}
		results := &MockResultProvider{}
		sequences := &MockSequenceProvider{}

		system := &System{
			Pending:           NewDefaultSubmissionList(),
			Submitter:         submitter,
			Results:           results,
			Sequences:         sequences,
			SubmissionQueue:   sequence.NewManager(),
			NetworkPassphrase: build.TestNetwork.Passphrase,
		}

		noResults := Result{Err: ErrNoResults}
		successTx := Result{
			Hash:           "2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d",
			LedgerSequence: 2,
			EnvelopeXDR:    "AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECDzqvkQBQoNAJifPRXDoLhvtycT3lFPCQ51gkdsFHaBNWw05S/VhW0Xgkr0CBPE4NaFV2Kmcs3ZwLmib4TRrML",
			ResultXDR:      "I3Tpk0m57326ml2zM5t4/ajzR3exrzO6RorVwN+UbU0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==",
		}

		badSeq := SubmissionResult{
			Err: ErrBadSequence,
		}

		sequences.Results = map[string]uint64{
			"GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H": 0,
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
				So(len(l), ShouldEqual, 1)
				<-l
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
