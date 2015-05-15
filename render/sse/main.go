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
	SseData() interface{}
}

type HasId interface {
	SseId() string
}

type HasEvent interface {
	SseEvent() string
}

type Streamer struct {
	Ctx  context.Context
	Data <-chan Event
}

type ErrorEvent struct {
	Error error
}

func (e ErrorEvent) SseData() interface{} {
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
	writeHelloEvent(w)
	for {
		select {
		case event, more := <-s.Data:
			if !more {
				writeGoodbyeEvent(w)
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
		fmt.Fprintf(w, "id: %s\n", e.SseId())
	}

	if e, ok := e.(HasEvent); ok {
		fmt.Fprintf(w, "event: %s\n", e.SseEvent())
	}

	fmt.Fprintf(w, "data: %s\n\n", getJson(e.SseData()))
	w.(http.Flusher).Flush()
}

// Transmits the hello message to the provided client.
//
// Upon initial stream creation, we send this event to inform the client
// that they may retry an errored connection after 1 second.
func writeHelloEvent(w http.ResponseWriter) {
	fmt.Fprintf(w, "retry: %d\n", 1000)
	fmt.Fprintf(w, "event: %s\n", "open")
	fmt.Fprintf(w, "data: %s\n\n", "hello")
	w.(http.Flusher).Flush()
}

// Transmits the goodbye message to the connected client.
//
// Upon successful completion of a query (i.e. the client didn't disconnect
// and we didn't error) we send a "Goodbye" event.  This is a dummy event
// so that we can set a low retry value so that the client will immediately
// recoonnect and request more data.  This helpes to give the feel of a infinite
// stream of data, even though we're actually responding in PAGE_SIZE chunks.
func writeGoodbyeEvent(w http.ResponseWriter) {
	fmt.Fprintf(w, "retry: %d\n", 10)
	fmt.Fprintf(w, "event: %s\n", "close")
	fmt.Fprintf(w, "data: %s\n\n", "byebye")
	w.(http.Flusher).Flush()
}

func getJson(val interface{}) string {
	js, err := json.Marshal(val)

	if err != nil {
		log.Panic(err)
	}

	return string(js)
}
