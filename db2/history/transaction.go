package history

import (
	sq "github.com/Masterminds/squirrel"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/toid"
)

// TransactionByHash is a query that loads a single row from the
// `history_transactions` table based upon the provided hash.
func (q *Q) TransactionByHash(dest interface{}, hash string) error {
	sql := selectTransaction.
		Limit(1).
		Where("ht.transaction_hash = ?", hash)

	return q.Get(dest, sql)
}

// Transactions provides a helper to filter rows from the `history_transactions`
// table with pre-defined filters.  See `TransactionsQ` methods for the
// available filters.
func (q *Q) Transactions() *TransactionsQ {
	return &TransactionsQ{
		parent: q,
		sql:    selectTransaction,
	}
}

// ForAccount filters the transactions collection to a specific account
func (q *TransactionsQ) ForAccount(aid string) *TransactionsQ {
	var account Account
	q.Err = q.parent.AccountByAddress(&account, aid)
	if q.Err != nil {
		return q
	}

	q.sql = q.sql.
		Join("history_transaction_participants htp ON htp.history_transaction_id = ht.id").
		Where("htp.history_account_id = ?", account.ID)

	return q
}

// ForLedger filters the query to a only transactions in a specific ledger,
// specified by its sequence.
func (q *TransactionsQ) ForLedger(seq int32) *TransactionsQ {
	var ledger Ledger
	q.Err = q.parent.LedgerBySequence(&ledger, seq)
	if q.Err != nil {
		return q
	}

	start := toid.ID{LedgerSequence: seq}
	end := toid.ID{LedgerSequence: seq + 1}
	q.sql = q.sql.Where(
		"ht.id >= ? AND ht.id < ?",
		start.ToInt64(),
		end.ToInt64(),
	)

	return q
}

// Page specifies the paging constraints for the query being built by `q`.
func (q *TransactionsQ) Page(page db2.PageQuery) *TransactionsQ {
	if q.Err != nil {
		return q
	}

	q.sql, q.Err = page.ApplyTo(q.sql, "ht.id")
	return q
}

// Select loads the results of the query specified by `q` into `dest`.
func (q *TransactionsQ) Select(dest interface{}) error {
	if q.Err != nil {
		return q.Err
	}

	q.Err = q.parent.Select(dest, q.sql)
	return q.Err
}

var selectTransaction = sq.Select(
	"ht.id, " +
		"ht.transaction_hash, " +
		"ht.ledger_sequence, " +
		"ht.application_order, " +
		"ht.account, " +
		"ht.account_sequence, " +
		"ht.fee_paid, " +
		"ht.operation_count, " +
		"ht.tx_envelope, " +
		"ht.tx_result, " +
		"ht.tx_meta, " +
		"ht.tx_fee_meta, " +
		"ht.created_at, " +
		"ht.updated_at, " +
		"array_to_string(ht.signatures, ',') AS signatures, " +
		"ht.memo_type, " +
		"ht.memo, " +
		"lower(ht.time_bounds) AS valid_after, " +
		"upper(ht.time_bounds) AS valid_before, " +
		"hl.closed_at AS ledger_close_time").
	From("history_transactions ht").
	LeftJoin("history_ledgers hl ON ht.ledger_sequence = hl.sequence")
