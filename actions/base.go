package actions

import (
	"net/http"

	gctx "github.com/goji/context"

	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/render/sse"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
)

// Base is a helper struct you can use as part of a custom action via
// composition.
//
// TODO: example usage
type Base struct {
	Ctx     context.Context
	GojiCtx web.C
	W       http.ResponseWriter
	R       *http.Request
	Err     error
}

// Prepare established the common attributes that get used in nearly every
// action.  "Child" actions may override this method to extend action, but it
// is advised you also call this implementation to maintain behavior.
func (base *Base) Prepare(c web.C, w http.ResponseWriter, r *http.Request) {
	base.Ctx = gctx.FromC(c)
	base.GojiCtx = c
	base.W = w
	base.R = r
}

// Execute trigger content negottion and the actual execution of one of the
// action's handlers.
func (base *Base) Execute(action interface{}) {
	contentType := render.Negotiate(base.Ctx, base.R)

	switch contentType {
	case render.MimeHal, render.MimeJSON:
		action, ok := action.(JSON)

		if !ok {
			goto NotAcceptable
		}

		action.JSON()

		if base.Err != nil {
			problem.Render(base.Ctx, base.W, base.Err)
			return
		}

	case render.MimeEventStream:
		action, ok := action.(SSE)
		if !ok {
			goto NotAcceptable
		}

		stream, ok := sse.NewStream(base.Ctx, base.W, base.R)
		if !ok {
			return
		}

		for {
			action.SSE(stream)

			if stream.IsDone() {
				return
			}

			select {
			case <-base.Ctx.Done():
				return
			case <-sse.Pumped():
				//no-op, continue onto the next iteration
			}

		}
	default:
		goto NotAcceptable
	}
	return

NotAcceptable:
	problem.Render(base.Ctx, base.W, problem.NotAcceptable)
	return
}
