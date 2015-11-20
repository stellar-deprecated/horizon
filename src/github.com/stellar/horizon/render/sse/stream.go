package sse

import (
	"net/http"

	"golang.org/x/net/context"
)

// Stream represents an output stream that data can be written to
type Stream interface {
	Send(Event)
	SentCount() int
	Done()
	SetLimit(limit int)
	IsDone() bool
	Err(error)
}

// NewStream creates a new stream against the provided response writer
func NewStream(ctx context.Context, w http.ResponseWriter, r *http.Request) (Stream, bool) {
	result := &stream{ctx, w, r, false, 0, 0}
	ok := WritePreamble(ctx, w)
	return result, ok
}

type stream struct {
	ctx   context.Context
	w     http.ResponseWriter
	r     *http.Request
	done  bool
	sent  int
	limit int
}

func (s *stream) Send(e Event) {
	WriteEvent(s.ctx, s.w, e)
	s.sent++
}

func (s *stream) SentCount() int {
	return s.sent
}

func (s *stream) SetLimit(limit int) {
	s.limit = limit
}

func (s *stream) Done() {
	WriteEvent(s.ctx, s.w, goodbyeEvent)
	s.done = true
}

func (s *stream) IsDone() bool {
	if s.limit == 0 {
		return s.done
	}

	return s.done || s.sent >= s.limit
}

func (s *stream) Err(err error) {
	WriteEvent(s.ctx, s.w, Event{Error: err})
	s.done = true
}
