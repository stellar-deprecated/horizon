package horizon

import (
	"github.com/rcrowley/go-metrics"
	"github.com/rs/cors"
	"github.com/zenazn/goji/web"
	"io"
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
	api.Get("/", helloWorld)

	return &result, nil
}

func helloWorld(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Hello world")
}
