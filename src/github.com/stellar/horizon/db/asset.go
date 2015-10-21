package db

import (
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
)

// This file contains helpers for working with stellar assets

func assetFromDB(typ int32, code string, issuer string) (result xdr.Asset, err error) {
	switch xdr.AssetType(typ) {
	case xdr.AssetTypeAssetTypeNative:
		result, err = xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)
	case xdr.AssetTypeAssetTypeCreditAlphanum4:
		var (
			an      xdr.AssetAlphaNum4
			decoded []byte
			pkey    xdr.Uint256
		)

		copy(an.AssetCode[:], []byte(code))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, issuer)
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

		copy(an.AssetCode[:], []byte(code))
		decoded, err = strkey.Decode(strkey.VersionByteAccountID, issuer)
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
