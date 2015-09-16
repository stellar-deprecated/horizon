package txsub

import (
	"golang.org/x/net/context"
	"time"
)

// openSubmission tracks a slice of channels that should be emitted to when we
// know the result for the transactions with the provided hash
type openSubmission struct {
	Hash        string
	SubmittedAt time.Time
	Listeners   []chan<- Result
}

func hashForEnvelope(ctx context.Context, env string) (string, error) {
	return "", nil
}
