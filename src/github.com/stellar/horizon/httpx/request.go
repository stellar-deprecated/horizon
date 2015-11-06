package httpx

import (
	"net/http"

	"golang.org/x/net/context"
)

var requestContextKey = 0

func RequestFromContext(ctx context.Context) *http.Request {
	found := ctx.Value(&requestContextKey)

	if found == nil {
		return nil
	}

	return found.(*http.Request)
}

// RequestContext returns a context representing the provided http action.
// It also integrates `http.CloseNotifier` with `context.Context`, returning a context
// that will be canceled when the http connection underlying `w` is closed.
func RequestContext(parent context.Context, w http.ResponseWriter, r *http.Request) (context.Context, func()) {
	if r == nil {
		panic("Cannot bind nil *http.Request to context tree")
	}

	ctx, cancel := context.WithCancel(parent)
	notifier, ok := w.(http.CloseNotifier)

	var closedByClient <-chan bool

	if ok {
		closedByClient = notifier.CloseNotify()
	} else {
		closedByClient = make(chan bool)
	}

	// listen for the connection to close, trigger cancelation
	go func() {
		select {
		case <-closedByClient:
			cancel()
		case <-ctx.Done():
			return
		}
	}()

	return context.WithValue(ctx, &requestContextKey, r), cancel
}
