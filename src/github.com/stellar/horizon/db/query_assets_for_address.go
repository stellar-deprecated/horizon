package db

import (
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/xdr"
	"golang.org/x/net/context"
)

// AssetsForAddress retrieves a slice of xdr.Asset structs which the provided
// address can hold a balance.  Used by the path finding system to load potential
// source assets, for example.
type AssetsForAddressQuery struct {
	SqlQuery
	Address string
}

func (q AssetsForAddressQuery) Select(ctx context.Context, dest interface{}) error {
	var tls []CoreTrustlineRecord

	tlq := CoreTrustlinesByAddressQuery{q.SqlQuery, q.Address}
	err := Select(ctx, tlq, &tls)
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
		result[i], err = assetFromDB(tl.Assettype, tl.Assetcode, tl.Issuer)
		if err != nil {
			return err
		}
	}

	result[len(result)-1], err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)

	return err
}
