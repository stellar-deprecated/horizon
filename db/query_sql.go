package db

import (
	"database/sql"
	"github.com/jmoiron/sqlx"
	sq "github.com/lann/squirrel"
)

type SqlQuery struct {
	DB *sql.DB
}

func (q SqlQuery) Select(sql sq.SelectBuilder, dest interface{}) error {
	db := sqlx.NewDb(q.DB, "postgres")
	sql = sql.PlaceholderFormat(sq.Dollar)
	query, args, err := sql.ToSql()

	if err != nil {
		return err
	}

	return db.Select(dest, query, args...)
}
