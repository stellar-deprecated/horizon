package txsub

import (
	"net/http"
)

// submitter is the default implementation for the Submitter interface.  It
// submits directly to the configured stellar-core instance using the
// configured http client.
type submitter struct {
	http    *http.Client
	coreURL string
}

// Submit sends the provided envelope to stellar-core and parses the response into
// a SubmissionResult
func (sub *submitter) Submit(env string) SubmissionResult {
	return SubmissionResult{}

}
