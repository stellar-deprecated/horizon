package db

import (
	"github.com/go-errors/errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

// ConnectedAssetsQuery returns xdr.Asset records for the purposes of path
// finding.  Given the input asset type, a list of xdr.Assets is returned that
// each have some available trades for the input asset.
type ConnectedAssetsQuery struct {
	SqlQuery
	SellingAsset xdr.Asset
}

func (q ConnectedAssetsQuery) Select(ctx context.Context, dest interface{}) error {

	assets, ok := dest.(*[]xdr.Asset)
	if !ok {
		return errors.New("dest is not *[]xdr.Asset")
	}

	var (
		t xdr.AssetType
		c string
		i string
	)

	err := q.SellingAsset.Extract(&t, &c, &i)
	if err != nil {
		return err
	}

	sql := sq.Select(
		"buyingassettype AS type",
		"coalesce(buyingassetcode, '') AS code",
		"coalesce(buyingissuer, '') AS issuer").
		From("offers").
		Where(sq.Eq{"sellingassettype": t}).
		GroupBy("buyingassettype", "buyingassetcode", "buyingissuer")

	if t != xdr.AssetTypeAssetTypeNative {
		sql = sql.Where(sq.Eq{"sellingassetcode": c, "sellingissuer": i})
	}

	var rows []struct {
		Type   xdr.AssetType
		Code   string
		Issuer string
	}

	err = q.SqlQuery.Select(ctx, sql, &rows)

	if err != nil {
		return err
	}

	results := make([]xdr.Asset, len(rows))
	*assets = results

	for i, r := range rows {
		results[i], err = assetFromDB(r.Type, r.Code, r.Issuer)
		if err != nil {
			return err
		}
	}

	return nil
}
