package db

import (
	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
)

// Commit commits the transaction.
func (tx *Tx) Commit() error {
	err := tx.TX.Commit()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return nil
}

// Delete returns a new delete builder
func (tx *Tx) Delete(from string) sq.DeleteBuilder {
	return sq.Delete(from)
}

// Exec executes a single query within the transaction, recording the
// result and error on the TX itself.
//
// If a previous error has occurred on this transaction, this call will be a no
// op.
func (tx *Tx) Exec(query string, args ...interface{}) {
	if tx.Err != nil {
		return
	}
	var err error
	tx.Result, err = tx.TX.Exec(query, args...)

	if err != nil {
		tx.Err = errors.Wrap(err, 1)
	}
}

// ExecDelete executes the provided delete builder
func (tx *Tx) ExecDelete(del sq.DeleteBuilder) {
	if tx.Err != nil {
		return
	}

	sql, args, err := del.
		PlaceholderFormat(sq.Dollar).
		ToSql()

	if err != nil {
		tx.Err = errors.Wrap(err, 1)
		return
	}

	tx.Exec(sql, args...)
}

// ExecInsert executes the provided insert builder
func (tx *Tx) ExecInsert(ib sq.InsertBuilder) {
	if tx.Err != nil {
		return
	}

	sql, args, err := ib.
		PlaceholderFormat(sq.Dollar).
		ToSql()

	if err != nil {
		tx.Err = errors.Wrap(err, 1)
		return
	}

	tx.Exec(sql, args...)
}

// Insert returns a new insert builder
func (tx *Tx) Insert(into string) sq.InsertBuilder {
	return sq.Insert(into)
}

// Rollback runs rollback directly on the underlying transaction
func (tx *Tx) Rollback() error {
	err := tx.TX.Rollback()

	if err != nil {
		return errors.Wrap(err, 1)
	}

	return nil
}
