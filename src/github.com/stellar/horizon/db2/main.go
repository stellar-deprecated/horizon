// Package db2 is the replacement for db.  It provides low level db connection
// and query capabilities.
package db2

import (
	"database/sql"
	"regexp"
	"strings"

	"github.com/go-errors/errors"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"golang.org/x/net/context"
)

// Conn represents a connection to a single database.
type Conn interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	Get(dest interface{}, query string, args ...interface{}) error
	Rebind(sql string) string
	Queryx(query string, args ...interface{}) (*sqlx.Rows, error)
	Select(dest interface{}, query string, args ...interface{}) error
}

// Pageable records have a defined order, and the place withing that order
// is determined by the paging token
type Pageable interface {
	PagingToken() string
}

// PageQuery represents a portion of a Query struct concerned with paging
// through a large dataset.
type PageQuery struct {
	Cursor string
	Order  string
	Limit  uint64
}

// Repo provides helper methods for making queries against `Conn`, such as
// logging.
type Repo struct {
	// Conn is the database connection that queries should be executed against.
	DB *sqlx.DB

	// Ctx is the optional context in which the repo is operating under.
	Ctx context.Context

	tx *sqlx.Tx
}

// AllStatements takes a sql script, possibly containing comments and multiple
// statements, and returns a slice of strings that correspond to each individual
// SQL statement within the script
func AllStatements(script string) (ret []string) {
	for _, s := range strings.Split(removeComments(script), ";") {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		ret = append(ret, s)
	}
	return
}

// Open the postgres database at `url` and returns a new *Repo using it.
func Open(url string) (*Repo, error) {
	db, err := sqlx.Connect("postgres", url)
	if err != nil {
		return nil, errors.Wrap(err, 1)
	}

	return &Repo{DB: db}, nil
}

// ensure various types conform to Conn interface
var _ Conn = (*sqlx.Tx)(nil)
var _ Conn = (*sqlx.DB)(nil)

// SQLBlockComments is a regex that matches against SQL block comments
var sqlBlockComments = regexp.MustCompile(`/\*.*?\*/`)

// SQLLineComments is a regex that matches against SQL line comments
var sqlLineComments = regexp.MustCompile("--.*?\n")

func removeComments(script string) string {
	withoutBlocks := sqlBlockComments.ReplaceAllString(script, "")
	return sqlLineComments.ReplaceAllString(withoutBlocks, "")
}
