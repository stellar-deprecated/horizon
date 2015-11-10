package resource

import (
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
)

func (b *Balance) Populate(row db.CoreTrustlineRecord) (err error) {
	b.Type, err = assets.String(row.Assettype)
	if err != nil {
		return
	}

	b.Balance = amount.String(row.Balance)
	b.Limit = amount.String(row.Tlimit)
	b.Issuer = row.Issuer
	b.Code = row.Assetcode
	return
}

func (b *Balance) PopulateNative(stroops xdr.Int64) (err error) {
	b.Type, err = assets.String(xdr.AssetTypeAssetTypeNative)
	if err != nil {
		return
	}

	b.Balance = amount.String(stroops)
	b.Limit = ""
	b.Issuer = ""
	b.Code = ""
	return
}
