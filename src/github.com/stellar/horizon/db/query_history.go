package db

// NOTE: this file is a temporary home for the SelectBuilders associated with
// querying the core database.

import (
	sq "github.com/lann/squirrel"
)

// Provides a squirrel.SelectBuilder upon which you may build actual queries.
var TransactionRecordSelect sq.SelectBuilder = sq.
	Select(
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
