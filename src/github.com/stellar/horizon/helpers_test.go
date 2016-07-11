package horizon

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"testing"

	"github.com/PuerkitoBio/throttled"
	hlog "github.com/stellar/horizon/log"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/test"
)

// StartHTTPTest is a helper function to setup a new test that will make http
// requests. Pair it with a deferred call to FinishHTTPTest.
func StartHTTPTest(
	t *testing.T,
	scenario string,
) (*App, *test.T, test.RequestHelper) {
	tt := test.Start(t).Scenario(scenario)
	app := NewTestApp()
	rh := NewRequestHelper(app)

	return app, tt, rh
}

// FinishHTTPTest closed out a test function that was initialized using
// `StartHTTPTest`
func FinishHTTPTest(app *App, tt *test.T) {
	tt.Finish()
	app.Close()
}

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

func ShouldBeProblem(a interface{}, options ...interface{}) string {
	body := a.(*bytes.Buffer)
	expected := options[0].(problem.P)

	problem.Inflate(test.Context(), &expected)

	var actual problem.P
	err := json.Unmarshal(body.Bytes(), &actual)

	if err != nil {
		return fmt.Sprintf("Could not unmarshal json into problem struct:\n%s\n", body.String())
	}

	if expected.Type != "" && actual.Type != expected.Type {
		return fmt.Sprintf("Mismatched problem type: %s expected, got %s", expected.Type, actual.Type)
	}

	if expected.Status != 0 && actual.Status != expected.Status {
		return fmt.Sprintf("Mismatched problem status: %d expected, got %d", expected.Status, actual.Status)
	}

	return ""
}
