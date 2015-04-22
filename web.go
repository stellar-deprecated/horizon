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
	failureMeter metrics.Meter
	successMeter metrics.Meter
}

func NewWeb(app *App) (*Web, error) {

	api := web.New()
	result := Web{
		router:       api,
		requestTimer: metrics.NewTimer(),
		failureMeter: metrics.NewMeter(),
		successMeter: metrics.NewMeter(),
	}

	app.metrics.Register("requests.total", result.requestTimer)
	app.metrics.Register("requests.succeeded", result.successMeter)
	app.metrics.Register("requests.failed", result.failureMeter)

	api.Use(appMiddleware(app))
	api.Use(requestMetricsMiddleware)

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
	})
	api.Use(c.Handler)

	// define routes
	api.Get("/", rootAction)
	api.Get("/metrics", metricsAction)

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
