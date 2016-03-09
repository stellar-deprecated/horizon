package db2

import (
	"database/sql"

	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Get runs `query`, setting the first result found on `dest`, if
// any.
func (r *Repo) Get(dest interface{}, query sq.Sqlizer) error {
	sql, args, err := r.build(query)
	if err != nil {
		return err
	}
	return r.GetRaw(dest, sql, args...)
}

// GetRaw runs `query` with `args`, setting the first result found on
// `dest`, if any.
func (r *Repo) GetRaw(dest interface{}, query string, args ...interface{}) error {
	r.log("get", query, args)
	return r.Conn.Get(dest, query, args...)
}

// Exec runs `query`
func (r *Repo) Exec(query sq.Sqlizer) (sql.Result, error) {
	sql, args, err := r.build(query)
	if err != nil {
		return nil, err
	}
	return r.ExecRaw(sql, args...)
}

// ExecRaw runs `query` with `args`
func (r *Repo) ExecRaw(query string, args ...interface{}) (sql.Result, error) {
	r.log("exec", query, args)
	return r.Conn.Exec(query, args...)
}

// Select runs `query`, setting the results found on `dest`.
func (r *Repo) Select(dest interface{}, query sq.Sqlizer) error {
	sql, args, err := r.build(query)
	if err != nil {
		return err
	}
	return r.SelectRaw(dest, sql, args...)
}

// SelectRaw runs `query` with `args`, setting the results found on `dest`.
func (r *Repo) SelectRaw(dest interface{}, query string, args ...interface{}) error {
	r.log("get", query, args)
	return r.Conn.Select(dest, query, args...)
}

// build converts the provided sql builder `b` into the sql and args to execute
// against the raw database connections.
func (r *Repo) build(b sq.Sqlizer) (sql string, args []interface{}, err error) {
	switch b := b.(type) {
	case sq.DeleteBuilder:
		sql, args, err = b.PlaceholderFormat(sq.Dollar).ToSql()
	case sq.InsertBuilder:
		sql, args, err = b.PlaceholderFormat(sq.Dollar).ToSql()
	case sq.UpdateBuilder:
		sql, args, err = b.PlaceholderFormat(sq.Dollar).ToSql()
	default:
		sql, args, err = b.ToSql()
	}

	if err != nil {
		err = errors.Wrap(err, 1)
	}
	return
}

func (r *Repo) log(typ string, query string, args []interface{}) {
	ctx := context.Background()
	if r.Ctx != nil {
		ctx = r.Ctx
	}

	log.
		Ctx(ctx).
		WithField("args", args).
		WithField("sql", query).
		Debugf("sql: %s", typ)
}
