package db

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db/records/history"
	"golang.org/x/net/context"
)

var EffectRecordSelect sq.SelectBuilder = sq.
	Select("heff.*, hacc.address").
	From("history_effects heff").
	LeftJoin("history_accounts hacc ON hacc.id = heff.history_account_id")

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
	var account history.Account
	err := Get(ctx, HistoryAccountByAddressQuery{f.SqlQuery, f.AccountAddress}, &account)

	if err != nil {
		return sql, err
	}

	return sql.Where("heff.history_account_id = ?", account.ID), nil
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
	var tx history.Transaction
	err := Get(ctx, TransactionByHashQuery{f.SqlQuery, f.TransactionHash}, &tx)

	if err != nil {
		return sql, nil
	}

	start := ParseTotalOrderID(tx.ID)
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
