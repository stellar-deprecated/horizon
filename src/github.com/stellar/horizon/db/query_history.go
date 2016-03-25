package db

// NOTE: this file is a temporary home for the SelectBuilders associated with
// querying the core database.

import (
	sq "github.com/lann/squirrel"
)

// HistoryAccountRecordSelect is a reusable select builder to make it easier
// to query upon the history_accounts table
var HistoryAccountRecordSelect = sq.
	Select("ha.*").
	From("history_accounts ha")

var LedgerRecordSelect sq.SelectBuilder = sq.Select(
	"hl.id",
	"hl.sequence",
	"hl.importer_version",
	"hl.ledger_hash",
	"hl.previous_ledger_hash",
	"hl.transaction_count",
	"hl.operation_count",
	"hl.closed_at",
	"hl.created_at",
	"hl.updated_at",
	"hl.total_coins",
	"hl.fee_pool",
	"hl.base_fee",
	"hl.base_reserve",
	"hl.max_tx_set_size",
).From("history_ledgers hl")

var OperationRecordSelect sq.SelectBuilder = sq.
	Select(
	"hop.id, " +
		"hop.transaction_id, " +
		"hop.application_order, " +
		"hop.type, " +
		"hop.details, " +
		"hop.source_account, " +
		"ht.transaction_hash").
	From("history_operations hop").
	LeftJoin("history_transactions ht ON ht.id = hop.transaction_id")

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
