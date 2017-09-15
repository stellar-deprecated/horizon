package horizon

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"

	"github.com/PuerkitoBio/throttled"
	hlog "github.com/stellar/horizon/pkg/log"
	"github.com/stellar/horizon/pkg/test"
)

func NewTestApp() *App {
	app, err := NewApp(NewTestConfig())

	if err != nil {
		log.Panic(err)
	}

	return app
}

func NewTestConfig() Config {
	return Config{
		DatabaseURL:            test.DatabaseURL(),
		StellarCoreDatabaseURL: test.StellarCoreDatabaseURL(),
		RateLimit:              throttled.PerHour(1000),
		LogLevel:               hlog.InfoLevel,
	}
}

func NewRequestHelper(app *App) test.RequestHelper {
	return test.NewRequestHelper(app.web.router)
}

func ShouldBePageOf(actual interface{}, options ...interface{}) string {
	body := actual.(*bytes.Buffer)
	expected := options[0].(int)

	var result map[string]interface{}
	err := json.Unmarshal(body.Bytes(), &result)

	if err != nil {
		return fmt.Sprintf("Could not unmarshal json:\n%s\n", body.String())
	}

	embedded, ok := result["_embedded"]

	if !ok {
		return "No _embedded key in response"
	}

	records, ok := embedded.(map[string]interface{})["records"]

	if !ok {
		return "No records key in _embedded"
	}

	length := len(records.([]interface{}))

	if length != expected {
		return fmt.Sprintf("Expected %d records in page, got %d", expected, length)
	}

	return ""
}
