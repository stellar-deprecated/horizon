package db

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"golang.org/x/net/context"
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

var EffectRecordSelect sq.SelectBuilder = sq.
	Select("heff.*, hacc.address").
	From("history_effects heff").
	LeftJoin("history_accounts hacc ON hacc.id = heff.history_account_id")

type EffectRecord struct {
	HistoryAccountID   int64          `db:"history_account_id"`
	Account            string         `db:"address"`
	HistoryOperationID int64          `db:"history_operation_id"`
	Order              int32          `db:"order"`
	Type               int32          `db:"type"`
	DetailsString      sql.NullString `db:"details"`
}

func (r EffectRecord) UnmarshalDetails(dest interface{}) error {
	if !r.DetailsString.Valid {
		return nil
	}

	err := json.Unmarshal([]byte(r.DetailsString.String), &dest)
	if err != nil {
		err = errors.Wrap(err, 1)
	}

	return err
}

// ID returns a lexically ordered id for this effect record
func (r EffectRecord) ID() string {
	return fmt.Sprintf("%019d-%010d", r.HistoryOperationID, r.Order)
}

func (r EffectRecord) PagingToken() string {
	return fmt.Sprintf("%d-%d", r.HistoryOperationID, r.Order)
}

// SQLFilter implementerations

// EffectTypeFilter represents a filter that excludes all rows that do not match the
// type specified by the filter
type EffectTypeFilter struct {
	Type int32
}

func (f *EffectTypeFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	return sql.Where("heff.type = ?", f.Type), nil
}

// EffectAccountFilter represents a filter that excludes all rows that do not apply to
// the account specified
type EffectAccountFilter struct {
	SqlQuery
	AccountAddress string
}

func (f *EffectAccountFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	var account HistoryAccountRecord
	err := Get(ctx, HistoryAccountByAddressQuery{f.SqlQuery, f.AccountAddress}, &account)

	if err != nil {
		return sql, err
	}

	return sql.Where("heff.history_account_id = ?", account.Id), nil
}

// EffectLedgerFilter represents a filter that excludes all rows that did not occur
// in the specified ledger
type EffectLedgerFilter struct {
	LedgerSequence int32
}

func (f *EffectLedgerFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	start := TotalOrderID{LedgerSequence: f.LedgerSequence}
	end := TotalOrderID{LedgerSequence: f.LedgerSequence + 1}
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}

// EffectTransactionFilter represents a filter that excludes all rows that did not occur
// in the specified transaction
type EffectTransactionFilter struct {
	SqlQuery
	TransactionHash string
}

func (f *EffectTransactionFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	var tx TransactionRecord
	err := Get(ctx, TransactionByHashQuery{f.SqlQuery, f.TransactionHash}, &tx)

	if err != nil {
		return sql, nil
	}

	start := ParseTotalOrderID(tx.Id)
	end := start
	end.TransactionOrder++
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}

// EffectOperationFilter represents a filter that excludes all rows that did not occur
// in the specified operation
type EffectOperationFilter struct {
	OperationID int64
}

func (f *EffectOperationFilter) Apply(ctx context.Context, sql sq.SelectBuilder) (sq.SelectBuilder, error) {
	start := ParseTotalOrderID(f.OperationID)
	end := start
	end.IncOperationOrder()
	return sql.Where(
		"(heff.history_operation_id >= ? AND heff.history_operation_id < ?)",
		start.ToInt64(),
		end.ToInt64(),
	), nil
}

// EffectOrderBookFilter represents a filter that excludes all rows that did not occur
// in the specified order book
type EffectOrderBookFilter struct {
	SellingType   xdr.AssetType
	SellingCode   string
	SellingIssuer string
	BuyingType    xdr.AssetType
	BuyingCode    string
	BuyingIssuer  string
}

func (f *EffectOrderBookFilter) Apply(ctx context.Context, in sq.SelectBuilder) (sql sq.SelectBuilder, err error) {
	sql = in

	sellingType, err := assets.String(f.SellingType)
	if err != nil {
		return
	}

	buyingType, err := assets.String(f.BuyingType)
	if err != nil {
		return
	}

	if f.SellingType == xdr.AssetTypeAssetTypeNative {
		sql = sql.Where(`
				(heff.details->>'sold_asset_type' = ?
		AND heff.details ?? 'sold_asset_code' = false
		AND heff.details ?? 'sold_asset_issuer' = false)`,
			sellingType,
		)
	} else {
		sql = sql.Where(`
				(heff.details->>'sold_asset_type' = ?
		AND heff.details->>'sold_asset_code' = ?
		AND heff.details->>'sold_asset_issuer' = ?)`,
			sellingType,
			f.SellingCode,
			f.SellingIssuer,
		)
	}

	if f.BuyingType == xdr.AssetTypeAssetTypeNative {
		sql = sql.Where(`
				(heff.details->>'bought_asset_type' = ?
		AND heff.details ?? 'bought_asset_code' = false
		AND heff.details ?? 'bought_asset_issuer' = false)`,
			buyingType,
		)
	} else {
		sql = sql.Where(`
				(heff.details->>'bought_asset_type' = ?
		AND heff.details->>'bought_asset_code' = ?
		AND heff.details->>'bought_asset_issuer' = ?)`,
			buyingType,
			f.BuyingCode,
			f.BuyingIssuer,
		)
	}

	if err != nil {
		return
	}

	return
}
