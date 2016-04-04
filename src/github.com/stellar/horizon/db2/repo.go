package db2

import (
	"database/sql"
	"time"

	"github.com/go-errors/errors"
	"github.com/jmoiron/sqlx"
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// Begin binds this repo to a new transaction.
func (r *Repo) Begin() error {
	if r.tx != nil {
		return errors.New("already in transaction")
	}

	tx, err := r.DB.Beginx()
	if err != nil {
		return errors.Wrap(err, 1)
	}
	r.logBegin()

	r.tx = tx
	return nil
}

// Clone clones the receiver, returning a new instance backed by the same
// context and db. The result will not be bound to any transaction that the
// source is currently within.
func (r *Repo) Clone() *Repo {
	return &Repo{
		DB:  r.DB,
		Ctx: r.Ctx,
	}
}

// Commit commits the current transaction
func (r *Repo) Commit() error {
	if r.tx == nil {
		return errors.New("not in transaction")
	}

	err := r.tx.Commit()
	r.logCommit()
	r.tx = nil
	return err
}

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
	query = r.conn().Rebind(query)
	start := time.Now()
	err := r.conn().Get(dest, query, args...)
	r.log("get", start, query, args)

	if err == nil {
		return nil
	}

	if r.NoRows(err) {
		return err
	}

	return errors.Wrap(err, 1)
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
	query = r.conn().Rebind(query)
	start := time.Now()
	result, err := r.conn().Exec(query, args...)
	r.log("exec", start, query, args)

	if err == nil {
		return result, nil
	}

	if r.NoRows(err) {
		return nil, err
	}

	return nil, errors.Wrap(err, 1)
}

// NoRows returns true if the provided error resulted from a query that found
// no results.
func (r *Repo) NoRows(err error) bool {
	return err == sql.ErrNoRows
}

// Query runs `query`, returns a *sqlx.Rows instance
func (r *Repo) Query(query sq.Sqlizer) (*sqlx.Rows, error) {
	sql, args, err := r.build(query)
	if err != nil {
		return nil, err
	}
	return r.QueryRaw(sql, args...)
}

// QueryRaw runs `query` with `args`
func (r *Repo) QueryRaw(query string, args ...interface{}) (*sqlx.Rows, error) {
	query = r.conn().Rebind(query)
	start := time.Now()
	result, err := r.conn().Queryx(query, args...)
	r.log("query", start, query, args)

	if err == nil {
		return result, nil
	}

	if r.NoRows(err) {
		return nil, err
	}

	return nil, errors.Wrap(err, 1)
}

// Rollback rolls back the current transaction
func (r *Repo) Rollback() error {
	if r.tx == nil {
		return errors.New("not in transaction")
	}

	err := r.tx.Rollback()
	r.logRollback()
	r.tx = nil
	return err
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
	query = r.conn().Rebind(query)
	start := time.Now()
	err := r.conn().Select(dest, query, args...)
	r.log("select", start, query, args)

	if err == nil {
		return nil
	}

	if r.NoRows(err) {
		return err
	}

	return errors.Wrap(err, 1)
}

// build converts the provided sql builder `b` into the sql and args to execute
// against the raw database connections.
func (r *Repo) build(b sq.Sqlizer) (sql string, args []interface{}, err error) {
	sql, args, err = b.ToSql()

	if err != nil {
		err = errors.Wrap(err, 1)
	}
	return
}

func (r *Repo) conn() Conn {
	if r.tx != nil {
		return r.tx
	}

	return r.DB
}

func (r *Repo) log(typ string, start time.Time, query string, args []interface{}) {
	log.
		Ctx(r.logCtx()).
		WithField("args", args).
		WithField("sql", query).
		WithField("dur", time.Since(start).String()).
		Debugf("sql: %s", typ)
}

func (r *Repo) logBegin() {
	log.Ctx(r.logCtx()).Debug("sql: begin")
}

func (r *Repo) logCommit() {
	log.Ctx(r.logCtx()).Debug("sql: commit")
}

func (r *Repo) logRollback() {
	log.Ctx(r.logCtx()).Debug("sql: rollbacl")
}

func (r *Repo) logCtx() context.Context {
	if r.Ctx != nil {
		return r.Ctx
	}

	return context.Background()
}
