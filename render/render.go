package render

import (
	"net/http"
	"time"

	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/render/sse"
	"golang.org/x/net/context"
)

type JSONResponder func()
type SSEResponder func(sse.Stream)

type Renderer struct {
	JSON JSONResponder
	SSE  SSEResponder
}

func (renderer *Renderer) Render(ctx context.Context, w http.ResponseWriter, r *http.Request) {
	contentType := Negotiate(ctx, r)

	switch contentType {
	case MimeHal, MimeJSON:
		if renderer.JSON == nil {
			goto NotAcceptable
		}

		renderer.JSON()
	case MimeEventStream:
		if renderer.SSE == nil {
			goto NotAcceptable
		}

		stream, ok := sse.NewStream(ctx, w, r)
		if !ok {
			return
		}

		for {

			renderer.SSE(stream)

			if stream.IsDone() {
				return
			}
			<-time.After(1 * time.Second)
		}
	default:
		goto NotAcceptable
	}
	return

NotAcceptable:
	problem.Render(ctx, w, problem.NotAcceptable)
	return
}
