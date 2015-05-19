package render

import (
	"errors"
	"net/http"

	"bitbucket.org/ww/goautoneg"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/render/sse"
	"golang.org/x/net/context"
)

const (
	MimeEventStream = "text/event-stream"
	MimeHal         = "application/hal+json"
	MimeJson        = "application/json"
	MimeProblem     = "application/problem+json"
)

var (
	InvalidStreamEvent error
)

func init() {
	InvalidStreamEvent = errors.New("provided `Transform` did not return an implementer of `sse.Event`")
}

type Resource interface{}
type Transform func(db.Record) (Resource, error)
type ToEvent func(interface{}) sse.Event

func Collection(ctx context.Context, w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	contentType := Negotiate(r)

	switch contentType {
	case MimeHal, MimeJson:
		records, err := db.Results(ctx, q)
		if err != nil {
			panic(err)
		}

		// map the found records to hal compatible resources
		// using `t`
		resources := make([]interface{}, len(records))
		for i, record := range records {
			resource, err := t(record)

			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}

			resources[i] = resource
		}

		// TODO: add paging links
		page := hal.Page{
			Records: resources,
		}

		hal.RenderPage(w, page)
	case MimeEventStream:

		records := db.Stream(ctx, q)
		events := recordToEvent(records.Get(), func(r interface{}) sse.Event {
			resource, err := t(r)

			if err != nil {
				return sse.ErrorEvent{err}
			}

			event, ok := resource.(sse.Event)

			if !ok {
				return sse.ErrorEvent{InvalidStreamEvent}
			}

			return event
		})

		streamer := &sse.Streamer{ctx, events}
		streamer.ServeHTTP(w, r)
	default:
		http.Error(w, "bad accept", http.StatusNotAcceptable)
	}
}

func Single(ctx context.Context, w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	record, err := db.First(ctx, q)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	} else if record == nil {
		problem.Render(ctx, w, problem.NotFound)
		return
	} else {
		resource, err := t(record)

		if err != nil {
			p := problem.FromError(ctx, err)
			problem.Render(ctx, w, p)
			return
		}

		hal.Render(w, resource)
	}
}

func Negotiate(r *http.Request) string {
	alternatives := []string{MimeHal, MimeJson, MimeEventStream}
	accept := r.Header.Get("Accept")

	if accept == "" {
		return MimeHal
	}

	return goautoneg.Negotiate(r.Header.Get("Accept"), alternatives)
}

func recordToEvent(in <-chan db.StreamRecord, t ToEvent) <-chan sse.Event {
	chn := make(chan sse.Event)

	go func() {
		for sr := range in {
			err := sr.Err

			if err != nil {
				chn <- sse.ErrorEvent{err}
			} else {
				chn <- t(sr.Record)
			}

		}
		close(chn)
	}()

	return chn
}
