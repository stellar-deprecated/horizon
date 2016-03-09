// Package db2 is the replacement for db.  It provides low level db connection
// and query capabilities.
package db2

import (
	"database/sql"

	"github.com/jmoiron/sqlx"
	"golang.org/x/net/context"
)

// Conn represents a connection to a single database.
type Conn interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	Get(dest interface{}, query string, args ...interface{}) error
	Rebind(sql string) string
	Select(dest interface{}, query string, args ...interface{}) error
}

// Repo provides helper methods for making queries against `Conn`, such as
// logging.
type Repo struct {
	// Conn is the database connection that queries should be executed against.
	Conn

	// Ctx is the optional context in which the repo is operating under.
	Ctx context.Context
}

// ensure various types conform to Conn interface
var _ Conn = (*sqlx.Tx)(nil)
var _ Conn = (*sqlx.DB)(nil)
