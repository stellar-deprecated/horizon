package db

import (
	"database/sql"

	"github.com/jmoiron/sqlx"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-horizon/log"
	"golang.org/x/net/context"
)

type SqlQuery struct {
	DB *sql.DB
}

func (q SqlQuery) Select(ctx context.Context, sql sq.SelectBuilder, dest interface{}) error {
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return err
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

func (q SqlQuery) Get(ctx context.Context, sql sq.SelectBuilder, dest interface{}) error {
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return err
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
