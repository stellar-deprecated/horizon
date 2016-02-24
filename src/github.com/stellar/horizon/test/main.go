// Package test contains simple test helpers that should not
// have any dependencies on horizon's packages.  think constants,
// custom matchers, generic helpers etc.
package test

import (
	"bytes"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/Sirupsen/logrus"
	"github.com/jmoiron/sqlx"
	hlog "github.com/stellar/horizon/log"
	"github.com/stretchr/testify/assert"
	"golang.org/x/net/context"
)

//go:generate go get github.com/jteeuwen/go-bindata/go-bindata
//go:generate go-bindata -pkg test scenarios

var (
	coreDB    *sqlx.DB
	horizonDB *sqlx.DB
)

const (
	// DefaultTestDatabaseURL is the default postgres connection string for
	// horizon's test database.
	DefaultTestDatabaseURL = "postgres://localhost:5432/horizon_test?sslmode=disable"

	// DefaultTestStellarCoreDatabaseURL is the default postgres connection string
	// for horizon's test stellar core database.
	DefaultTestStellarCoreDatabaseURL = "postgres://localhost:5432/stellar-core_test?sslmode=disable"
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
func Database() *sqlx.DB {
	if horizonDB != nil {
		return horizonDB
	}
	horizonDB = OpenDatabase(DatabaseUrl())
	return horizonDB
}

// DatabaseUrl returns the database connection the url any test
// use when connecting to the history/horizon database
func DatabaseUrl() string {
	databaseURL := os.Getenv("DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultTestDatabaseURL
	}

	return databaseURL
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

// OpenDatabase opens a database, panicing if it cannot
func OpenDatabase(dsn string) *sqlx.DB {
	db, err := sqlx.Open("postgres", dsn)

	if err != nil {
		log.Panic(err)
	}

	return db
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

	result.Ctx = hlog.Set(context.Background(), result.Logger)
	result.HorizonDB = Database()
	result.CoreDB = StellarCoreDatabase()
	result.Assert = assert.New(t)

	return result
}

// StellarCoreDatabase returns a connection to the stellar core test database
func StellarCoreDatabase() *sqlx.DB {
	if coreDB != nil {
		return coreDB
	}
	coreDB = OpenDatabase(StellarCoreDatabaseUrl())
	return coreDB
}

// StellarCoreDatabaseUrl returns the database connection the url any test
// use when connecting to the stellar-core database
func StellarCoreDatabaseUrl() string {
	databaseURL := os.Getenv("STELLAR_CORE_DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultTestStellarCoreDatabaseURL
	}

	return databaseURL
}
