package sse

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Event is the packet of data that gets sent over the wire to a connected
// client.
type Event struct {
	Data  interface{}
	Error error
	ID    string
	Event string
	Retry int
}

// SseEvent returns the SSE compatible form of the Event... itself.
func (e Event) SseEvent() Event {
	return e
}

// Eventable represents an object that can be converted to an SSE compatible
// event.
type Eventable interface {
	// SseEvent returns the SSE compatible form of the implementer
	SseEvent() Event
}

// Pumped returns a channel that will be closed the next time the input pump
// sends.  It can be used similar to `ctx.Done()`, like so:  `<-sse.Pumped()`
func Pumped() <-chan struct{} {
	return nextTick
}

// Tick triggers any open SSE streams to tick by replacing and closing the
// `nextTick` trigger channel.
func Tick() {
	lock.Lock()
	prev := nextTick
	nextTick = make(chan struct{})
	lock.Unlock()
	close(prev)
}

// WritePreamble prepares this http connection for streaming using Server Sent
// Events.  It sends the initial http response with the appropriate headers to
// do so.
func WritePreamble(ctx context.Context, w http.ResponseWriter) bool {

	_, flushable := w.(http.Flusher)

	if !flushable {
		//TODO: render a problem struct instead of simple string
		http.Error(w, "Streaming Not Supported", http.StatusBadRequest)
		return false
	}

	w.Header().Set("Content-Type", "text/event-stream; charset=utf-8")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.WriteHeader(200)

	WriteEvent(ctx, w, helloEvent)

	return true
}

// WriteEvent does the actual work of formatting an SSE compliant message
// sending it over the provided ResponseWriter and flushing.
func WriteEvent(ctx context.Context, w http.ResponseWriter, e Event) {
	if e.Error != nil {
		fmt.Fprint(w, "event: err\n")
		fmt.Fprintf(w, "data: %s\n\n", e.Error.Error())
		w.(http.Flusher).Flush()
		log.Ctx(ctx).Error(e.Error)
		return
	}

	// TODO: add tests to ensure retry get's properly rendered
	if e.Retry != 0 {
		fmt.Fprintf(w, "retry: %d\n", e.Retry)
	}

	if e.ID != "" {
		fmt.Fprintf(w, "id: %s\n", e.ID)
	}

	if e.Event != "" {
		fmt.Fprintf(w, "event: %s\n", e.Event)
	}

	fmt.Fprintf(w, "data: %s\n\n", getJSON(e.Data))
	w.(http.Flusher).Flush()
}

// Upon successful completion of a query (i.e. the client didn't disconnect
// and we didn't error) we send a "Goodbye" event.  This is a dummy event
// so that we can set a low retry value so that the client will immediately
// recoonnect and request more data.  This helpes to give the feel of a infinite
// stream of data, even though we're actually responding in PAGE_SIZE chunks.
var goodbyeEvent = Event{
	Data:  "byebye",
	Event: "close",
	Retry: 10,
}

// Upon initial stream creation, we send this event to inform the client
// that they may retry an errored connection after 1 second.
var helloEvent = Event{
	Data:  "hello",
	Event: "open",
	Retry: 1000,
}

var lock sync.Mutex
var nextTick chan struct{}

func getJSON(val interface{}) string {
	js, err := json.Marshal(val)

	if err != nil {
		panic(err)
	}

	return string(js)
}
