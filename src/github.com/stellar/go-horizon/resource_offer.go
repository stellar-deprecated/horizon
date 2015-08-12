package horizon

import (
	"database/sql"
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
)

// OfferResource is the display form of an offer to trade currency.
type OfferResource struct {
	halgo.Links
	ID          int64                 `json:"id"`
	PagingToken string                `json:"paging_token"`
	Account     string                `json:"account"`
	Selling     OfferCurrencyResource `json:"selling"`
	Buying      OfferCurrencyResource `json:"buying"`
	Amount      int64                 `json:"amount"`
	Price       PriceResource         `json:"price"`
	PriceF      float64               `json:"price_f"`
}

// OfferCurrencyResource is the json resource for a currency component of
// an offer.
type OfferCurrencyResource struct {
	Type   string `json:"asset_type"`
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"asset_issuer,omitempty"`
}

// PriceResource is a price, used by offers, expressed as a fraction, N/D.
type PriceResource struct {
	N int32 `json:"numerator"`
	D int32 `json:"denominator"`
}

func NewOfferResource(op db.CoreOfferRecord) OfferResource {
	self := fmt.Sprintf("/offers/%d", op.Offerid)

	selling := NewOfferCurrencyResource(op.SellingAssetCode, op.SellingIssuer)
	buying := NewOfferCurrencyResource(op.BuyingAssetCode, op.BuyingIssuer)

	return OfferResource{
		Links: halgo.Links{}.
			Self(self).
			Link("offer_maker", "/accounts/%s", op.Accountid),
		ID:          op.Offerid,
		PagingToken: op.PagingToken(),
		Account:     op.Accountid,
		Selling:   selling,
		Buying:   buying,
		Amount:      op.Amount,
		Price: PriceResource{
			N: op.Pricen,
			D: op.Priced,
		},
		PriceF: op.PriceAsFloat(),
	}
}

// NewOfferCurrencyResource creates a new OfferCurrencyResource, ensuring that
// the code and issuer are consistent.  If both are null, we return a native
// currency.
func NewOfferCurrencyResource(code, issuer sql.NullString) OfferCurrencyResource {

	switch {
	case code.Valid && issuer.Valid:
		return OfferCurrencyResource{
			Type:   "alphanum",
			Code:   code.String,
			Issuer: issuer.String,
		}
	case !code.Valid && !issuer.Valid:
		return OfferCurrencyResource{Type: "native"}
	default:
		panic("Exceptional offer state: code and issuer are not both null or not-null")
	}

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
