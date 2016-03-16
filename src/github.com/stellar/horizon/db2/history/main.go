// Package history contains database record definitions useable for
// reading rows from a the history portion of horizon's database
package history

import (
	"time"

	"github.com/guregu/null"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2"
)

const (
	// account effects

	EffectAccountCreated           EffectType = 0 // from create_account
	EffectAccountRemoved           EffectType = 1 // from merge_account
	EffectAccountCredited          EffectType = 2 // from create_account, payment, path_payment, merge_account
	EffectAccountDebited           EffectType = 3 // from create_account, payment, path_payment, create_account
	EffectAccountThresholdsUpdated EffectType = 4 // from set_options
	EffectAccountHomeDomainUpdated EffectType = 5 // from set_options
	EffectAccountFlagsUpdated      EffectType = 6 // from set_options

	// signer effects

	EffectSignerCreated EffectType = 10 // from set_options
	EffectSignerRemoved EffectType = 11 // from set_options
	EffectSignerUpdated EffectType = 12 // from set_options

	// trustline effects

	EffectTrustlineCreated      EffectType = 20 // from change_trust
	EffectTrustlineRemoved      EffectType = 21 // from change_trust
	EffectTrustlineUpdated      EffectType = 22 // from change_trust, allow_trust
	EffectTrustlineAuthorized   EffectType = 23 // from allow_trust
	EffectTrustlineDeauthorized EffectType = 24 // from allow_trust

	// trading effects

	EffectOfferCreated EffectType = 30 // from manage_offer, creat_passive_offer
	EffectOfferRemoved EffectType = 31 // from manage_offer, creat_passive_offer, path_payment
	EffectOfferUpdated EffectType = 32 // from manage_offer, creat_passive_offer, path_payment
	EffectTrade        EffectType = 33 // from manage_offer, creat_passive_offer, path_payment
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
	Type               EffectType  `db:"type"`
	DetailsString      null.String `db:"details"`
}

// EffectType is the numeric type for an effect, used as the `type` field in the
// `history_effects` table.
type EffectType int

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

// Q is a helper struct on which to hang common queries against a history
// portion of the horizon database.
type Q struct {
	*db2.Repo
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

// LatestLedger loads the latest known ledger
func (q *Q) LatestLedger(dest interface{}) error {
	return q.GetRaw(dest, `SELECT COALESCE(MAX(sequence), 0) FROM history_ledgers`)
}
