// Package test contains simple test helpers that should not
// have any dependencies on horizon's packages.  think constants,
// custom matchers, generic helpers etc.
package test

import (
	"bytes"
	"database/sql"
	"log"
	"os"
	"os/exec"

	glog "github.com/stellar/go-horizon/log"
	"golang.org/x/net/context"
)

//go:generate go get github.com/jteeuwen/go-bindata/...
//go:generate go-bindata -pkg test scenarios

const (
	DefaultTestDatabaseUrl            = "postgres://localhost:5432/horizon_test?sslmode=disable"
	DefaultTestStellarCoreDatabaseUrl = "postgres://localhost:5432/stellar-core_test?sslmode=disable"
)

// DatabaseUrl returns the database connection the url any test
// use when connecting to the history/horizon database
func DatabaseUrl() string {
	databaseURL := os.Getenv("DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultTestDatabaseUrl
	}

	return databaseURL
}

// StellarCoreDatabaseUrl returns the database connection the url any test
// use when connecting to the stellar-core database
func StellarCoreDatabaseUrl() string {
	databaseURL := os.Getenv("STELLAR_CORE_DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultTestStellarCoreDatabaseUrl
	}

	return databaseURL
}

// OpenDatabase opens a database, panicing if it cannot
func OpenDatabase(dsn string) *sql.DB {
	db, err := sql.Open("postgres", dsn)

	if err != nil {
		log.Panic(err)
	}

	return db
}

// LoadScenario populates the test databases with pre-created scenarios.  Each
// scenario is in the scenarios subfolder of this package and are a pair of
// sql files, one per database.
func LoadScenario(scenarioName string) {
	scenarioBasePath := "scenarios/" + scenarioName
	horizonPath := scenarioBasePath + "-horizon.sql"
	stellarCorePath := scenarioBasePath + "-core.sql"

	loadSqlFile(DatabaseUrl(), horizonPath)
	loadSqlFile(StellarCoreDatabaseUrl(), stellarCorePath)
}

func loadSqlFile(url string, path string) {
	sql, err := Asset(path)

	if err != nil {
		log.Panic(err)
	}

	reader := bytes.NewReader(sql)
	cmd := exec.Command("psql", url)
	cmd.Stdin = reader

	err = cmd.Run()

	if err != nil {
		log.Panic(err)
	}

	_ = cmd.Wait()
}

// Context provides a context suitable for testing in tests that do not create
// a full App instance (in which case your tests should be using the app's
// context).  This context has a logger bound to it suitable for testing.
func Context() context.Context {
	return glog.Context(context.Background(), testLogger)
}
