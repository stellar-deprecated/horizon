package resource

import (
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
)

func (this *Balance) Populate(row db.CoreTrustlineRecord) (err error) {
	this.Type, err = assets.String(row.Assettype)
	if err != nil {
		return
	}

	this.Balance = amount.String(row.Balance)
	this.Limit = amount.String(row.Tlimit)
	this.Issuer = row.Issuer
	this.Code = row.Assetcode
	return
}

func (this *Balance) PopulateNative(stroops xdr.Int64) (err error) {
	this.Type, err = assets.String(xdr.AssetTypeAssetTypeNative)
	if err != nil {
		return
	}

	this.Balance = amount.String(stroops)
	this.Limit = ""
	this.Issuer = ""
	this.Code = ""
	return
}
