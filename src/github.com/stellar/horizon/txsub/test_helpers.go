package txsub

// This file provides mock implementations for the txsub interfaces
// which are useful in a testing context.
//
// NOTE:  this file is not a test file so that other packages may import
// txsub and use these mocks in their own tests

import (
	"golang.org/x/net/context"
)

// MockSubmitter is a test helper that simplements the Submitter interface
type MockSubmitter struct {
	R              SubmissionResult
	WasSubmittedTo bool
}

// Submit implements `txsub.Submitter`
func (sub *MockSubmitter) Submit(ctx context.Context, env string) SubmissionResult {
	sub.WasSubmittedTo = true
	return sub.R
}

// MockResultProvider is a test helper that simplements the ResultProvider
// interface
type MockResultProvider struct {
	Results []Result
}

// ResultByHash implements `txsub.ResultProvider`
func (results *MockResultProvider) ResultByHash(ctx context.Context, hash string) (r Result) {
	if len(results.Results) > 0 {
		r = results.Results[0]
		results.Results = results.Results[1:]
	} else {
		r = Result{Err: ErrNoResults}
	}

	return
}

// MockSequenceProvider is a test helper that simplements the SequenceProvider
// interface
type MockSequenceProvider struct {
	Results map[string]uint64
	Err     error
}

// Get implements `txsub.SequenceProvider`
func (results *MockSequenceProvider) Get(addresses []string) (map[string]uint64, error) {
	return results.Results, results.Err
}
