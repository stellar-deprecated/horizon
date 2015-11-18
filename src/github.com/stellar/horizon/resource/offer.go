package resource

import (
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

func (this *Offer) Populate(ctx context.Context, row db.CoreOfferRecord) {
	this.ID = row.OfferID
	this.PT = row.PagingToken()
	this.Seller = row.SellerID
	this.Amount = amount.String(row.Amount)
	this.PriceR.N = row.Pricen
	this.PriceR.D = row.Priced
	this.Price = row.PriceAsString()
	this.Buying = Asset{
		Type:   assets.MustString(row.BuyingAssetType),
		Code:   row.BuyingAssetCode.String,
		Issuer: row.BuyingIssuer.String,
	}
	this.Selling = Asset{
		Type:   assets.MustString(row.SellingAssetType),
		Code:   row.SellingAssetCode.String,
		Issuer: row.SellingIssuer.String,
	}

	lb := hal.LinkBuilder{httpx.Host(ctx)}
	this.Links.Self = lb.Linkf("/offers/%d", row.OfferID)
	this.Links.OfferMaker = lb.Linkf("/accounts/%s", row.SellerID)
	return
}

func (this Offer) PagingToken() string {
	return this.PT
}
