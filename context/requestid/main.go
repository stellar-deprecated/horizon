// This package provides functions to support embedded and retrieving
// a request id from a go context tree
package requestid

import (
	"github.com/zenazn/goji/web"
	"github.com/zenazn/goji/web/middleware"
	"golang.org/x/net/context"
)

var key struct{}

// Establishes a context from the provided parent and the provided request id
// string.
//
// Returns the derived context
func Context(ctx context.Context, reqid string) context.Context {
	return context.WithValue(ctx, &key, reqid)
}

func ContextFromC(ctx context.Context, c *web.C) context.Context {
	reqid := middleware.GetReqID(*c)
	return Context(ctx, reqid)
}

// Returns the set request id, if one has been set, from the provided context
// returns "" if no requestid has been set
func FromContext(ctx context.Context) string {
	result, ok := ctx.Value(&key).(string)

	if ok {
		return result
	} else {
		return ""
	}
}
