package render

import (
	"errors"
	"net/http"

	"bitbucket.org/ww/goautoneg"
	"github.com/Sirupsen/logrus"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/log"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/stellar/go-horizon/render/sse"
	"golang.org/x/net/context"
)

const (
	//MimeEventStream is the mime type for "text/event-stream"
	MimeEventStream = "text/event-stream"
	//MimeHal is the mime type for "application/hal+json"
	MimeHal = "application/hal+json"
	//MimeJSON is the mime type for "application/json"
	MimeJSON = "application/json"
	//MimeProblem is the mime type for application/problem+json"
	MimeProblem = "application/problem+json"
)

var (
	// ErrInvalidStreamEvent is emitted when the returned value of a given
	// transform function returns a resource that cannot be converted into an
	// sse.Event.
	ErrInvalidStreamEvent = errors.New("provided `Transform` did not return an implementer of `sse.Eventable`")
)

// Resource gets rendered to HAL-compatible json.
type Resource interface{}

// Transform takes a database record and should return a Resource that will
// get transformed into JSON and rendered to the requesting client.
type Transform func(db.Record) (Resource, error)

// Collection renders multiple records, retrieved using q, as a HAL-formatted page.
//
// In the event that `r` is requesting a streamed response, we register a
// listener with the database streaming system and forward rendering on to the
// SSE system.
func Collection(ctx context.Context, w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	contentType := Negotiate(ctx, r)

	switch contentType {
	case MimeHal, MimeJSON:
		records, err := db.Results(ctx, q)

		if err != nil {
			problem.Render(ctx, w, err)
			return
		}

		// map the found records to hal compatible resources
		// using `t`
		resources := make([]interface{}, len(records))
		for i, record := range records {
			resource, err := t(record)

			if err != nil {
				problem.Render(ctx, w, err)
				return
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
		events := recordToEvent(records.Get(), t)
		streamer := &sse.Streamer{
			Ctx:  ctx,
			Data: events,
		}
		streamer.ServeHTTP(w, r)
	default:
		problem.Render(ctx, w, problem.NotAcceptable)
	}
}

// Single triggers the rendering of a singular resource.
func Single(ctx context.Context, w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	record, err := db.First(ctx, q)

	if err != nil {
		problem.Render(ctx, w, err)
		return
	} else if record == nil {
		problem.Render(ctx, w, problem.NotFound)
		return
	} else {
		resource, err := t(record)

		if err != nil {
			problem.Render(ctx, w, err)
			return
		}

		hal.Render(w, resource)
	}
}

// Negotiate inspects the Accept header of the provided request and determines
// what the most appropriate response type should be.  Defaults to HAL.
func Negotiate(ctx context.Context, r *http.Request) string {
	alternatives := []string{MimeHal, MimeJSON, MimeEventStream}
	accept := r.Header.Get("Accept")

	if accept == "" {
		return MimeHal
	}

	result := goautoneg.Negotiate(r.Header.Get("Accept"), alternatives)

	log.WithFields(ctx, logrus.Fields{
		"content_type": result,
		"accept":       accept,
	}).Debug("Negotiated content type")

	return result
}

func recordToEvent(in <-chan db.StreamRecord, t Transform) <-chan sse.Eventable {
	chn := make(chan sse.Eventable)

	go func() {
		for sr := range in {
			err := sr.Err

			if err != nil {
				chn <- sse.Event{Error: err}
				continue
			}

			resource, err := t(sr.Record)
			if err != nil {
				chn <- sse.Event{Error: err}
				continue
			}

			eventable, ok := resource.(sse.Eventable)

			if !ok {
				chn <- sse.Event{Error: ErrInvalidStreamEvent}
				continue
			}

			chn <- eventable
		}
		close(chn)
	}()

	return chn
}
