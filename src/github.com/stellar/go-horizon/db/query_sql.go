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
	db := sqlx.NewDb(q.DB, "postgres")
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return err
	}

	log.WithField(ctx, "sql", query).Info("Executing query")

	return db.Select(dest, query, args...)
}

func (q SqlQuery) Get(ctx context.Context, sql sq.SelectBuilder, dest interface{}) error {
	db := sqlx.NewDb(q.DB, "postgres")
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return err
	}
	return db.Get(dest, query, args...)
}
