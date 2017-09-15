// Package test contains simple test helpers that should not
// have any dependencies on horizon's packages.  think constants,
// custom matchers, generic helpers etc.
package test

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/jmoiron/sqlx"
	"github.com/sirupsen/logrus"
	hlog "github.com/stellar/horizon/log"
	tdb "github.com/stellar/horizon/test/db"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"golang.org/x/net/context"
)

// StaticMockServer is a test helper that records it's last request
type StaticMockServer struct {
	*httptest.Server
	LastRequest *http.Request
}

// T provides a common set of functionality for each test in horizon
type T struct {
	T          *testing.T
	Assert     *assert.Assertions
	Require    *require.Assertions
	Ctx        context.Context
	HorizonDB  *sqlx.DB
	CoreDB     *sqlx.DB
	Logger     *hlog.Entry
	LogMetrics *hlog.Metrics
	LogBuffer  *bytes.Buffer
}

// Context provides a context suitable for testing in tests that do not create
// a full App instance (in which case your tests should be using the app's
// context).  This context has a logger bound to it suitable for testing.
func Context() context.Context {
	return hlog.Set(context.Background(), testLogger)
}

// ContextWithLogBuffer returns a context and a buffer into which the new, bound
// logger will write into.  This method allows you to inspect what data was
// logged more easily in your tests.
func ContextWithLogBuffer() (context.Context, *bytes.Buffer) {
	output := new(bytes.Buffer)
	l, _ := hlog.New()
	l.Logger.Out = output
	l.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
	l.Logger.Level = logrus.DebugLevel

	ctx := hlog.Set(context.Background(), l)
	return ctx, output

}

// Database returns a connection to the horizon test database
//
// DEPRECATED:  use `Horizon()` from test/db package
func Database() *sqlx.DB {
	return tdb.Horizon()
}

// DatabaseURL returns the database connection the url any test
// use when connecting to the history/horizon database
//
// DEPRECATED:  use `HorizonURL()` from test/db package
func DatabaseURL() string {
	return tdb.HorizonURL()
}

// LoadScenario populates the test databases with pre-created scenarios.  Each
// scenario is in the scenarios subfolder of this package and are a pair of
// sql files, one per database.
func LoadScenario(scenarioName string) {
	loadScenario(scenarioName, true)
}

// LoadScenarioWithoutHorizon populates the test Stellar core database a with
// pre-created scenario.  Unlike `LoadScenario`, this
func LoadScenarioWithoutHorizon(scenarioName string) {
	loadScenario(scenarioName, false)
}

// OverrideLogger sets the default logger used by horizon to `l`.  This is used
// by the testing system so that we can collect output from logs during test
// runs.  Panics if the logger is already overridden.
func OverrideLogger(l *hlog.Entry) {
	if oldDefault != nil {
		panic("logger already overridden")
	}

	oldDefault = hlog.DefaultLogger
	hlog.DefaultLogger = l
}

// RestoreLogger restores the default horizon logger after it is overridden
// using a call to `OverrideLogger`.  Panics if the default logger is not
// presently overridden.
func RestoreLogger() {
	if oldDefault == nil {
		panic("logger not overridden, cannot restore")
	}

	hlog.DefaultLogger = oldDefault
	oldDefault = nil
}

// Start initializes a new test helper object and conceptually "starts" a new
// test
func Start(t *testing.T) *T {
	result := &T{}

	result.T = t
	result.LogBuffer = new(bytes.Buffer)
	result.Logger, result.LogMetrics = hlog.New()
	result.Logger.Logger.Out = result.LogBuffer
	result.Logger.Logger.Formatter.(*logrus.TextFormatter).DisableColors = true
	result.Logger.Logger.Level = logrus.DebugLevel

	OverrideLogger(result.Logger)

	result.Ctx = hlog.Set(context.Background(), result.Logger)
	result.HorizonDB = Database()
	result.CoreDB = StellarCoreDatabase()
	result.Assert = assert.New(t)
	result.Require = require.New(t)

	return result
}

// StellarCoreDatabase returns a connection to the stellar core test database
//
// DEPRECATED:  use `StellarCore()` from test/db package
func StellarCoreDatabase() *sqlx.DB {
	return tdb.StellarCore()
}

// StellarCoreDatabaseURL returns the database connection the url any test
// use when connecting to the stellar-core database
//
// DEPRECATED:  use `StellarCoreURL()` from test/db package
func StellarCoreDatabaseURL() string {
	return tdb.StellarCoreURL()
}

var oldDefault *hlog.Entry = nil
