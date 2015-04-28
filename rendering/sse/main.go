package sse

import (
	"encoding/json"
	"fmt"
	"golang.org/x/net/context"
	"log"
	"net/http"
)

// If a struct that we want to stream to the connected client implements this
// interface we will include the Id and Event fields in the payload, if they are
// set.
type Event interface {
	Data() interface{}
	Id() *string
	Event() *string
}

type Streamer struct {
	Ctx  context.Context
	Data <-chan interface{}
}

func (s *Streamer) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	flusher, flushable := w.(http.Flusher)

	if !flushable {
		//TODO: render a problem struct instead of simple string
		http.Error(w, "Streaming Not Supported", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithCancel(s.Ctx)
	defer cancel()
	close := w.(http.CloseNotifier).CloseNotify()
	go func() {
		<-close
		cancel()
	}()

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
		case record, more := <-s.Data:
			if !more {
				return
			}

			asEvent, isEvent := record.(Event)

			// if we can extract an event interface, use that
			// to populate this chunk
			if isEvent {
				id := asEvent.Id()
				event := asEvent.Event()

				if id != nil {
					fmt.Fprintf(w, "id: %s\n", *id)
				}

				if event != nil {
					fmt.Fprintf(w, "event: %s\n", *event)
				}

				fmt.Fprintf(w, "data: %s\n\n", getJson(asEvent.Data()))

			} else {
				// otherwise, just render the provided data
				fmt.Fprintf(w, "data: %s\n\n", getJson(record))
			}

			flusher.Flush()
		case <-ctx.Done():
			return
		}
	}
}

func getJson(val interface{}) string {
	js, err := json.Marshal(val)

	if err != nil {
		log.Panic(err)
	}

	return string(js)
}
