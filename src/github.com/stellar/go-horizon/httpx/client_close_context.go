package httpx

import (
	"golang.org/x/net/context"
	"net/http"
)

// Integrates `http.CloseNotifier` with `context.Context`, returning a context
// that will be canceled when the http connection underlying `w` is closed.
func CancelWhenClosed(parent context.Context, w http.ResponseWriter) context.Context {
	ctx, cancel := context.WithCancel(parent)

	close := w.(http.CloseNotifier).CloseNotify()

	// listen for the connection to close, trigger cancelation
	go func() {
		<-close
		cancel()
	}()

	return ctx
}
