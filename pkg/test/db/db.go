// Package db provides helpers to connect to test databases.  It has no
// internal dependencies on horizon and so should be able to be imported by
// any horizon package.
package db

import (
	"log"
	"os"

	"github.com/jmoiron/sqlx"
	// pq enables postgres support
	_ "github.com/lib/pq"
)

var (
	coreDB    *sqlx.DB
	horizonDB *sqlx.DB
)

const (
	// DefaultHorizonURL is the default postgres connection string for
	// horizon's test database.
	DefaultHorizonURL = "postgres://localhost:5432/horizon_test?sslmode=disable"

	// DefaultStellarCoreURL is the default postgres connection string
	// for horizon's test stellar core database.
	DefaultStellarCoreURL = "postgres://localhost:5432/stellar-core_test?sslmode=disable"
)

// Horizon returns a connection to the horizon test database
func Horizon() *sqlx.DB {
	if horizonDB != nil {
		return horizonDB
	}
	horizonDB = OpenDatabase(HorizonURL())
	return horizonDB
}

// HorizonURL returns the database connection the url any test
// use when connecting to the history/horizon database
func HorizonURL() string {
	databaseURL := os.Getenv("DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultHorizonURL
	}

	return databaseURL
}

// OpenDatabase opens a database, panicing if it cannot
func OpenDatabase(dsn string) *sqlx.DB {
	db, err := sqlx.Open("postgres", dsn)

	if err != nil {
		log.Panic(err)
	}

	return db
}

// StellarCore returns a connection to the stellar core test database
func StellarCore() *sqlx.DB {
	if coreDB != nil {
		return coreDB
	}
	coreDB = OpenDatabase(StellarCoreURL())
	return coreDB
}

// StellarCoreURL returns the database connection the url any test
// use when connecting to the stellar-core database
func StellarCoreURL() string {
	databaseURL := os.Getenv("STELLAR_CORE_DATABASE_URL")

	if databaseURL == "" {
		databaseURL = DefaultStellarCoreURL
	}

	return databaseURL
}
