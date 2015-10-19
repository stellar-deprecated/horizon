package db

import (
	"github.com/go-errors/errors"
	"github.com/jmoiron/sqlx"
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// SqlQuery helps facilitate queries against a postgresql database. See Select and Get for
// the main methods used by collaborators.
type SqlQuery struct {
	DB *sqlx.DB
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
	log.WithField(ctx, "sql", query).Info("query sql")
	log.WithField(ctx, "args", args).Debug("query args")

	err := q.DB.Select(dest, query, args...)
	if err != nil {
		err = errors.Wrap(err, 1)
	}
	return err
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
	log.WithField(ctx, "sql", query).Info("query sql")
	log.WithField(ctx, "args", args).Debug("query args")

	err := q.DB.Get(dest, query, args...)
	if err != nil {
		err = errors.Wrap(err, 1)
	}
	return err
}

func (q SqlQuery) Query(ctx context.Context, sql sq.SelectBuilder) (*sqlx.Rows, error) {
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return nil, errors.Wrap(err, 1)
	}

	return q.QueryRaw(ctx, query, args)
}

// QueryRaw runs the provided query and returns a *sqlx.Rows value to iterate through the response
func (q SqlQuery) QueryRaw(ctx context.Context, query string, args []interface{}) (*sqlx.Rows, error) {
	log.WithField(ctx, "sql", query).Info("query sql")
	log.WithField(ctx, "args", args).Debug("query args")

	rows, err := q.DB.Queryx(query, args...)
	if err != nil {
		err = errors.Wrap(err, 1)
	}
	return rows, err
}
