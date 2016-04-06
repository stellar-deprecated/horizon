package history

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/db2"
)

// Accounts provides a helper to filter rows from the `history_accounts` table
// with pre-defined filters.  See `AccountsQ` methods for the available filters.
func (q *Q) Accounts() *AccountsQ {
	return &AccountsQ{
		parent: q,
		sql:    selectAccount,
	}
}

// AccountByAddress loads a row from `history_accounts`, by address
func (q *Q) AccountByAddress(dest interface{}, addy string) error {
	sql := selectAccount.Limit(1).Where("ha.address = ?", addy)
	return q.Get(dest, sql)
}

// AccountByID loads a row from `history_accounts`, by id
func (q *Q) AccountByID(dest interface{}, id int64) error {
	sql := selectAccount.Limit(1).Where("ha.id = ?", id)
	return q.Get(dest, sql)
}

// Page specifies the paging constraints for the query being built by `q`.
func (q *AccountsQ) Page(page db2.PageQuery) *AccountsQ {
	if q.Err != nil {
		return q
	}

	q.sql, q.Err = page.ApplyTo(q.sql, "ha.id")
	return q
}

// Select loads the results of the query specified by `q` into `dest`.
func (q *AccountsQ) Select(dest interface{}) error {
	if q.Err != nil {
		return q.Err
	}

	q.Err = q.parent.Select(dest, q.sql)
	return q.Err
}

var selectAccount = sq.Select("ha.*").From("history_accounts ha")
