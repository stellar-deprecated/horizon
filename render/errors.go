package render

import "errors"

var (
	// ErrInvalidStreamEvent is emitted when the returned value of a given
	// transform function returns a resource that cannot be converted into an
	// sse.Event.
	ErrInvalidStreamEvent = errors.New("provided `Transform` did not return an implementer of `sse.Eventable`")
)
