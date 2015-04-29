package sse

import (
	"encoding/json"
	"fmt"
	"github.com/stellar/go-horizon/httpx"
	"golang.org/x/net/context"
	"log"
	"net/http"
)

// If the value that we want to stream to the connected client implements this
// interface we will include the Id and Event fields in the payload, if they are
// set.
type Event interface {
	Err() error
	Data() interface{}
}

type HasId interface {
	Id() string
}

type HasEvent interface {
	Event() string
}

type Streamer struct {
	Ctx  context.Context
	Data <-chan Event
}

type ErrorEvent struct {
	Error error
}

func (e ErrorEvent) Data() interface{} {
	return e.Error.Error()
}

func (e ErrorEvent) Err() error {
	return e.Error
}

func (s *Streamer) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	_, flushable := w.(http.Flusher)

	if !flushable {
		//TODO: render a problem struct instead of simple string
		http.Error(w, "Streaming Not Supported", http.StatusBadRequest)
		return
	}

	// Setup cancelation signal that gets triggered if the client disconnects
	ctx := httpx.CancelWhenClosed(s.Ctx, w)

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.WriteHeader(200)

	// wait for data and stream it as it becomes available
	// finish when either the client closes the connection
	// or the data provider closes the channel
	for {
		select {
		case event, more := <-s.Data:
			if !more {
				return
			}
			writeEvent(w, event)
		case <-ctx.Done():
			return
		}
	}
}

func writeEvent(w http.ResponseWriter, e Event) {
	if e.Err() != nil {
		fmt.Fprint(w, "event: error\n")
		fmt.Fprintf(w, "data: %s\n\n", e.Err().Error())
	}

	if e, ok := e.(HasId); ok {
		fmt.Fprintf(w, "id: %s\n", e.Id())
	}

	if e, ok := e.(HasEvent); ok {
		fmt.Fprintf(w, "event: %s\n", e.Event())
	}

	fmt.Fprintf(w, "data: %s\n\n", getJson(e.Data()))
	w.(http.Flusher).Flush()
}

func getJson(val interface{}) string {
	js, err := json.Marshal(val)

	if err != nil {
		log.Panic(err)
	}

	return string(js)
}
