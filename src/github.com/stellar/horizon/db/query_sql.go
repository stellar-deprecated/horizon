package db

import (
	"database/sql"

	"github.com/go-errors/errors"
	"github.com/jmoiron/sqlx"
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// SqlQuery helps facilitate queries against a postgresql database. See Select and Get for
// the main methods used by collaborators.
type SqlQuery struct {
	DB *sql.DB
}

// Select selects multiple rows returned by the provided sql builder into the provided dest.
// dest must be a slice of the correct record type.
func (q SqlQuery) Select(ctx context.Context, sql sq.SelectBuilder, dest interface{}) error {
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return q.SelectRaw(ctx, query, args, dest)
}

// SelectRaw runs the provided postgres query and args against this sqlquery's db.
func (q SqlQuery) SelectRaw(ctx context.Context, query string, args []interface{}, dest interface{}) error {
	db := sqlx.NewDb(q.DB, "postgres")
	log.WithField(ctx, "sql", query).Info("query sql")
	log.WithField(ctx, "args", args).Debug("query args")

	return db.Select(dest, query, args...)
}

// Get gets a single row returned by the provided sql builder into the provided dest.
// dest must be a non-slice value of the correct record type.
func (q SqlQuery) Get(ctx context.Context, sql sq.SelectBuilder, dest interface{}) error {
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return q.GetRaw(ctx, query, args, dest)
}

// GetRaw runs the provided postgres query and args against this sqlquery's db.
func (q SqlQuery) GetRaw(ctx context.Context, query string, args []interface{}, dest interface{}) error {
	db := sqlx.NewDb(q.DB, "postgres")
	log.WithField(ctx, "sql", query).Info("query sql")
	log.WithField(ctx, "args", args).Debug("query args")

	return db.Get(dest, query, args...)
}
