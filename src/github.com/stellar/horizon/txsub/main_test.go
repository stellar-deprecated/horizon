package txsub

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
