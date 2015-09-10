package httpx

import (
	"net/http"

	"golang.org/x/net/context"
)

var clientContextKey = 0
var defaultClient = &http.Client{}

// ClientFromContext retrieves a http.Client that has been bound to this context
// previously by a call to httpx.ClientContext, defaulting to a default Client
// if none has been bound
func ClientFromContext(ctx context.Context) *http.Client {
	found := ctx.Value(&clientContextKey)

	if found == nil {
		return defaultClient
	}

	return found.(*http.Client)
}

// ClientContext binds the provided client to a new context derived from the
// provided parent.  Use httpx.ClientFromContext to retrieve the client at some
// later point.
func ClientContext(parent context.Context, client *http.Client) context.Context {
	if client == nil {
		panic("Cannot bind nil *http.Client to context tree")
	}

	return context.WithValue(parent, &clientContextKey, client)
}
