package actions

import "github.com/stellar/horizon/render/sse"

// JSON implementors can respond to a request whose response type was negotiated
// to be MimeHal or MimeJSON.
type JSON interface {
	JSON()
}

// SSE implementors can respond to a request whose response type was negotiated
// to be MimeEventStream.
type SSE interface {
	SSE(sse.Stream)
}
