package simplepath

import (
	"github.com/stellar/go-stellar-base/strkey"
	"github.com/stellar/go-stellar-base/xdr"
)

func makeAsset(typ xdr.AssetType, code string, issuer string) xdr.Asset {

	if typ == xdr.AssetTypeAssetTypeNative {
		result, _ := xdr.NewAsset(typ, nil)
		return result
	}

	an := xdr.AssetAlphaNum4{}
	copy(an.AssetCode[:], code[:])

	raw := strkey.MustDecode(strkey.VersionByteAccountID, issuer)
	var key xdr.Uint256
	copy(key[:], raw)

	an.Issuer, _ = xdr.NewAccountId(xdr.CryptoKeyTypeKeyTypeEd25519, key)

	result, _ := xdr.NewAsset(typ, an)
	return result
}
