// Package history contains database record definitions useable for
// reading rows from a the history portion of horizon's database
package history

import (
	"time"

	"github.com/guregu/null"
	"github.com/stellar/go-stellar-base/xdr"
)

const (
	// account effects

	EffectAccountCreated           = 0 // from create_account
	EffectAccountRemoved           = 1 // from merge_account
	EffectAccountCredited          = 2 // from create_account, payment, path_payment, merge_account
	EffectAccountDebited           = 3 // from create_account, payment, path_payment, create_account
	EffectAccountThresholdsUpdated = 4 // from set_options
	EffectAccountHomeDomainUpdated = 5 // from set_options
	EffectAccountFlagsUpdated      = 6 // from set_options

	// signer effects

	EffectSignerCreated = 10 // from set_options
	EffectSignerRemoved = 11 // from set_options
	EffectSignerUpdated = 12 // from set_options

	// trustline effects

	EffectTrustlineCreated      = 20 // from change_trust
	EffectTrustlineRemoved      = 21 // from change_trust
	EffectTrustlineUpdated      = 22 // from change_trust, allow_trust
	EffectTrustlineAuthorized   = 23 // from allow_trust
	EffectTrustlineDeauthorized = 24 // from allow_trust

	// trading effects

	EffectOfferCreated = 30 // from manage_offer, creat_passive_offer
	EffectOfferRemoved = 31 // from manage_offer, creat_passive_offer, path_payment
	EffectOfferUpdated = 32 // from manage_offer, creat_passive_offer, path_payment
	EffectTrade        = 33 // from manage_offer, creat_passive_offer, path_payment
)

// Account is a row of data from the `history_accounts` table
type Account struct {
	TotalOrderID
	Address string `db:"address"`
}

// Effect is a row of data from the `history_effects` table
type Effect struct {
	HistoryAccountID   int64       `db:"history_account_id"`
	Account            string      `db:"address"`
	HistoryOperationID int64       `db:"history_operation_id"`
	Order              int32       `db:"order"`
	Type               int32       `db:"type"`
	DetailsString      null.String `db:"details"`
}

// Ledger is a row of data from the `history_ledgers` table
type Ledger struct {
	TotalOrderID
	Sequence           int32       `db:"sequence"`
	ImporterVersion    int32       `db:"importer_version"`
	LedgerHash         string      `db:"ledger_hash"`
	PreviousLedgerHash null.String `db:"previous_ledger_hash"`
	TransactionCount   int32       `db:"transaction_count"`
	OperationCount     int32       `db:"operation_count"`
	ClosedAt           time.Time   `db:"closed_at"`
	CreatedAt          time.Time   `db:"created_at"`
	UpdatedAt          time.Time   `db:"updated_at"`
	TotalCoins         int64       `db:"total_coins"`
	FeePool            int64       `db:"fee_pool"`
	BaseFee            int32       `db:"base_fee"`
	BaseReserve        int32       `db:"base_reserve"`
	MaxTxSetSize       int32       `db:"max_tx_set_size"`
}

// Operation is a row of data from the `history_operations` table
type Operation struct {
	TotalOrderID
	TransactionID    int64             `db:"transaction_id"`
	TransactionHash  string            `db:"transaction_hash"`
	ApplicationOrder int32             `db:"application_order"`
	Type             xdr.OperationType `db:"type"`
	DetailsString    null.String       `db:"details"`
	SourceAccount    string            `db:"source_account"`
}

// TotalOrderID represents the ID portion of rows that are identified by the
// "TotalOrderID".  See total_order_id.go in the `db` package for details.
type TotalOrderID struct {
	ID int64 `db:"id"`
}

// Transaction is a row of data from the `history_transactions` table
type Transaction struct {
	TotalOrderID
	TransactionHash  string      `db:"transaction_hash"`
	LedgerSequence   int32       `db:"ledger_sequence"`
	LedgerCloseTime  time.Time   `db:"ledger_close_time"`
	ApplicationOrder int32       `db:"application_order"`
	Account          string      `db:"account"`
	AccountSequence  string      `db:"account_sequence"`
	FeePaid          int32       `db:"fee_paid"`
	OperationCount   int32       `db:"operation_count"`
	TxEnvelope       string      `db:"tx_envelope"`
	TxResult         string      `db:"tx_result"`
	TxMeta           string      `db:"tx_meta"`
	TxFeeMeta        string      `db:"tx_fee_meta"`
	SignatureString  string      `db:"signatures"`
	MemoType         string      `db:"memo_type"`
	Memo             null.String `db:"memo"`
	ValidAfter       null.Int    `db:"valid_after"`
	ValidBefore      null.Int    `db:"valid_before"`
	CreatedAt        time.Time   `db:"created_at"`
	UpdatedAt        time.Time   `db:"updated_at"`
}
