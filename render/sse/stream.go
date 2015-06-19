package sse

import (
	"net/http"

	"golang.org/x/net/context"
)

type Stream interface {
	Send(Event)
	SentCount() int
	Done()
	IsDone() bool
	Err(error)
}

func NewStream(ctx context.Context, w http.ResponseWriter, r *http.Request) (Stream, bool) {
	result := &stream{ctx, w, r, false, 0}
	ok := WritePreamble(ctx, w)
	return result, ok
}

type stream struct {
	ctx  context.Context
	w    http.ResponseWriter
	r    *http.Request
	done bool
	sent int
}

func (s *stream) Send(e Event) {
	WriteEvent(s.ctx, s.w, e)
	s.sent++
}

func (s *stream) SentCount() int {
	return s.sent
}

func (s *stream) Done() {
	WriteEvent(s.ctx, s.w, goodbyeEvent)
	s.done = true
}

func (s *stream) IsDone() bool {
	return s.done
}

func (s *stream) Err(err error) {
	WriteEvent(s.ctx, s.w, Event{Error: err})
	s.done = true
}
