package db

import (
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/strkey"
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
		result[i], err = assetFromTrustline(tl)
		if err != nil {
			return err
		}
	}

	result[len(result)-1], err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)

	return err
}

func assetFromTrustline(tl CoreTrustlineRecord) (result xdr.Asset, err error) {
	switch xdr.AssetType(tl.Assettype) {
	case xdr.AssetTypeAssetTypeNative:
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)
	case xdr.AssetTypeAssetTypeCreditAlphanum4:
		var (
			an      xdr.AssetAlphaNum4
			decoded []byte
			pkey    xdr.Uint256
		)

		copy(an.AssetCode[:], []byte(tl.Assetcode))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, tl.Issuer)
		if err != nil {
			return
		}

		copy(pkey[:], decoded)
		an.Issuer, err = xdr.NewAccountId(xdr.CryptoKeyTypeKeyTypeEd25519, pkey)
		if err != nil {
			return
		}
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeCreditAlphanum4, an)
	case xdr.AssetTypeAssetTypeCreditAlphanum12:
		var (
			an      xdr.AssetAlphaNum12
			decoded []byte
			pkey    xdr.Uint256
		)

		copy(an.AssetCode[:], []byte(tl.Assetcode))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, tl.Issuer)
		if err != nil {
			return
		}

		copy(pkey[:], decoded)
		an.Issuer, err = xdr.NewAccountId(xdr.CryptoKeyTypeKeyTypeEd25519, pkey)
		if err != nil {
			return
		}
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeCreditAlphanum12, an)
	}

	return
}
