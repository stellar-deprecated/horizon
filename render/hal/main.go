package hal

import (
	"encoding/json"
	"github.com/jagregory/halgo"
	"net/http"
)

type Page struct {
	Self    halgo.Link
	Next    halgo.Link
	Records []interface{}
}

func RenderToString(data interface{}, pretty bool) ([]byte, error) {
	if pretty {
		return json.MarshalIndent(data, "", "  ")
	} else {
		return json.Marshal(data)
	}
}

func Render(w http.ResponseWriter, data interface{}) {
	js, err := RenderToString(data, true)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/hal+json")
	w.Write(js)
}

func RenderPage(w http.ResponseWriter, page Page) {
	data := map[string]interface{}{
		"_links": map[string]interface{}{
			"self": page.Self,
			"next": page.Next,
		},
		"_embedded": map[string]interface{}{
			"records": page.Records,
		},
	}

	Render(w, data)
}
