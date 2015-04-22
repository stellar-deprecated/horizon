package horizon

import (
	"encoding/json"
	"github.com/rcrowley/go-metrics"
	"github.com/rs/cors"
	"github.com/zenazn/goji/web"
	"net/http"
)

type Web struct {
	router *web.Mux

	requestTimer metrics.Timer
	errorMeter   metrics.Meter
	successMeter metrics.Meter
}

func NewWeb() (*Web, error) {

	api := web.New()
	result := Web{
		router:       api,
		requestTimer: metrics.NewTimer(),
		errorMeter:   metrics.NewMeter(),
		successMeter: metrics.NewMeter(),
	}

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})
	api.Use(c.Handler)

	// define routes
	api.Get("/", rootAction)

	return &result, nil
}

func renderHAL(w http.ResponseWriter, data interface{}) {
	js, err := json.Marshal(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/hal+json")
	w.Write(js)
}
