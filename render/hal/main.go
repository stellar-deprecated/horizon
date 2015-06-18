package hal

import (
	"encoding/json"
	"net/http"

	"github.com/jagregory/halgo"
)

// StandardPagingOptions is a helper string to make creating paged collection
// URIs simpler.
var StandardPagingOptions = "{?cursor,limit,order}"

type Page struct {
	halgo.Links
	Records []interface{}
}

// RenderToString renders the provided data as a json string
func RenderToString(data interface{}, pretty bool) ([]byte, error) {
	if pretty {
		return json.MarshalIndent(data, "", "  ")
	}

	return json.Marshal(data)
}

// Render write data to w, after marshalling to json
func Render(w http.ResponseWriter, data interface{}) {
	js, err := RenderToString(data, true)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/hal+json")
	w.Write(js)
}

// RenderPage writes page to w, after marshalling to json
func RenderPage(w http.ResponseWriter, page Page) {
	data := map[string]interface{}{
		"_links": page.Items,
		"_embedded": map[string]interface{}{
			"records": page.Records,
		},
	}

	Render(w, data)
}
