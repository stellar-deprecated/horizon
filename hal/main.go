package hal

import (
	"encoding/json"
	"net/http"
)

func Render(w http.ResponseWriter, data interface{}) {
	js, err := json.Marshal(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/hal+json")
	w.Write(js)
}

func RenderPage(w http.ResponseWriter, resources []interface{}) {
	data := map[string]interface{}{
		"_embedded": map[string]interface{}{
			"records": resources,
		},
	}

	js, err := json.Marshal(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/hal+json")
	w.Write(js)
}
