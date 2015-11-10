package horizon

import (
	"database/sql"
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

// OfferResource is the display form of an offer to trade currency.
type OfferResource struct {
	halgo.Links
	ID          int64              `json:"id"`
	PagingToken string             `json:"paging_token"`
	Seller      string             `json:"seller"`
	Selling     OfferAssetResource `json:"selling"`
	Buying      OfferAssetResource `json:"buying"`
	Amount      string             `json:"amount"`
	PriceR      PriceResource      `json:"price_r"`
	Price       string             `json:"price"`
}

// OfferAssetResource is the json resource for an asset component of
// an offer.
type OfferAssetResource struct {
	Type   string `json:"asset_type"`
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"issuer,omitempty"`
}

// PriceResource is a price, used by offers, expressed as a fraction, N/D.
type PriceResource struct {
	N int32 `json:"numerator"`
	D int32 `json:"denominator"`
}

// NewOfferResource converts a CoreOfferRecord into an OfferResource
func NewOfferResource(op db.CoreOfferRecord) OfferResource {
	self := fmt.Sprintf("/offers/%d", op.OfferID)

	buying := NewOfferAssetResource(op.BuyingAssetType, op.BuyingAssetCode, op.BuyingIssuer)
	selling := NewOfferAssetResource(op.SellingAssetType, op.SellingAssetCode, op.SellingIssuer)

	return OfferResource{
		Links: halgo.Links{}.
			Self(self).
			Link("offer_maker", "/accounts/%s", op.SellerID),
		ID:          op.OfferID,
		PagingToken: op.PagingToken(),
		Seller:      op.SellerID,
		Buying:      buying,
		Selling:     selling,
		Amount:      amount.String(op.Amount),
		PriceR: PriceResource{
			N: op.Pricen,
			D: op.Priced,
		},
		Price: op.PriceAsString(),
	}
}

// NewOfferAssetResource creates a new OfferAssetResource, ensuring that
// the code and issuer are consistent.  If both are null, we return a native
// asset type.
func NewOfferAssetResource(aType int32, code sql.NullString, issuer sql.NullString) OfferAssetResource {
	result := OfferAssetResource{
		Code:   code.String,
		Issuer: issuer.String,
	}

	switch xdr.AssetType(aType) {
	case xdr.AssetTypeAssetTypeNative:
		result.Type = "native"
	case xdr.AssetTypeAssetTypeCreditAlphanum4:
		result.Type = "credit_alphanum4"
	case xdr.AssetTypeAssetTypeCreditAlphanum12:
		result.Type = "credit_alphanum12"
	default:
		result.Type = fmt.Sprintf("unknown:%d", aType)
	}

	return result
}

func NewOfferResourcePage(records []db.CoreOfferRecord, query db.PageQuery, prefix string) (hal.Page, error) {
	fmts := prefix + "/offers?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		resources[i] = NewOfferResource(record)
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
