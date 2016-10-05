package core

import (
	"errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go/xdr"
)

// AssetsForAddress loads `dest` as `[]xdr.Asset` with every asset the account
// at `addy` can hold.
func (q *Q) AssetsForAddress(dest interface{}, addy string) error {
	var tls []Trustline

	err := q.TrustlinesByAddress(&tls, addy)
	if err != nil {
		return err
	}

	dtl, ok := dest.(*[]xdr.Asset)
	if !ok {
		return errors.New("Invalid destination")
	}

	result := make([]xdr.Asset, len(tls)+1)
	*dtl = result

	for i, tl := range tls {
		result[i], err = AssetFromDB(tl.Assettype, tl.Assetcode, tl.Issuer)
		if err != nil {
			return err
		}
	}

	result[len(result)-1], err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)

	return err
}

// TrustlinesByAddress loads all trustlines for `addy`
func (q *Q) TrustlinesByAddress(dest interface{}, addy string) error {
	sql := selectTrustline.Where("accountid = ?", addy)
	return q.Select(dest, sql)
}

var selectTrustline = sq.Select(
	"tl.accountid",
	"tl.assettype",
	"tl.issuer",
	"tl.assetcode",
	"tl.tlimit",
	"tl.balance",
	"tl.flags",
).From("trustlines tl")
