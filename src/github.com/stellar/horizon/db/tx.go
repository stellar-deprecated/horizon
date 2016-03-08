package db

import (
	"database/sql"

	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
)

// Commit commits the transaction.
func (tx *Tx) Commit() error {
	err := tx.tx.Commit()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return nil
}

// Delete returns a new delete builder
func (tx *Tx) Delete(from string) sq.DeleteBuilder {
	return sq.Delete(from).PlaceholderFormat(sq.Dollar)
}

// Exec executes the provided sql builder
func (tx *Tx) Exec(b sq.Sqlizer) (sql.Result, error) {
	var (
		sql  string
		args []interface{}
		err  error
	)

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
		return nil, errors.Wrap(err, 1)
	}

	return tx.exec(sql, args...)
}

// Insert returns a new insert builder
func (tx *Tx) Insert(into string) sq.InsertBuilder {
	return sq.Insert(into).PlaceholderFormat(sq.Dollar)
}

// Rollback runs rollback directly on the underlying transaction
func (tx *Tx) Rollback() error {
	err := tx.tx.Rollback()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return nil
}

// Exec executes a single query within the transaction, recording the
// result and error on the TX itself.
//
// If a previous error has occurred on this transaction, this call will be a no
// op.
func (tx *Tx) exec(query string, args ...interface{}) (sql.Result, error) {
	ret, err := tx.tx.Exec(query, args...)

	if err != nil {
		return nil, errors.Wrap(err, 1)
	}

	return ret, nil
}
