package txsub

// This file provides mock implementations for the txsub interfaces
// which are useful in a testing context.
//
// NOTE:  this file is not a test file so that other packages may import
// txsub and use these mocks in their own tests

import (
	"golang.org/x/net/context"
)

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

type MockSequenceProvider struct {
	Results map[string]uint64
	Err     error
}

func (results *MockSequenceProvider) Get(ctx context.Context, addresses []string) (map[string]uint64, error) {
	return results.Results, results.Err
}
