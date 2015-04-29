package render

import (
	"bitbucket.org/ww/goautoneg"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
	"net/http"
)

const (
	MimeEventStream = "text/event-stream"
	MimeHal         = "application/hal+json"
	MimeJson        = "application/json"
)

type Transform func(interface{}) interface{}

func Collection(w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	contentType := Negotiate(r)

	switch contentType {
	case MimeHal, MimeJson:
		records, err := db.Results(q)
		if err != nil {
			panic(err)
		}

		resources := make([]interface{}, len(records))
		for i, record := range records {
			resources[i] = t(record)
		}

		page := hal.Page{
			Records: resources,
		}

		hal.RenderPage(w, page)
	case MimeEventStream:
		http.Error(w, "bad accept", http.StatusNotAcceptable)
	default:
		http.Error(w, "bad accept", http.StatusNotAcceptable)
	}
}

func Single(w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	record, err := db.First(q)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	} else if record == nil {
		w.WriteHeader(http.StatusNotFound)
	} else {
		resource := t(record)
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
