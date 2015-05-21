package horizon

import (
	"database/sql"
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/sse"
)

// OfferResource is the display form of an offer to trade currency.
type OfferResource struct {
	halgo.Links
	ID          int64                 `json:"id"`
	PagingToken string                `json:"paging_token"`
	Account     string                `json:"account"`
	TakerPays   OfferCurrencyResource `json:"taker_pays"`
	TakerGets   OfferCurrencyResource `json:"taker_gets"`
	Amount      int64                 `json:"amount"`
	Price       PriceResource         `json:"price"`
	PriceF      float64               `json:"price_f"`
}

// OfferCurrencyResource is the json resource for a currency component of
// an offer.
type OfferCurrencyResource struct {
	Type   string `json:"currency_type"`
	Code   string `json:"currency_code,omitempty"`
	Issuer string `json:"currency_issuer,omitempty"`
}

// PriceResource is a price, used by offers, expressed as a fraction, N/D.
type PriceResource struct {
	N int32 `json:"numerator"`
	D int32 `json:"denominator"`
}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r OfferResource) SseEvent() sse.Event {
	return sse.Event{
		Data: r,
		ID:   r.PagingToken,
	}
}

func offerRecordToResource(record db.Record) (result render.Resource, err error) {

	op := record.(db.CoreOfferRecord)
	self := fmt.Sprintf("/offers/%d", op.Offerid)

	takerPays := NewOfferCurrencyResource(op.Paysalphanumcurrency, op.Paysissuer)
	takerGets := NewOfferCurrencyResource(op.Getsalphanumcurrency, op.Getsissuer)

	result = OfferResource{
		Links: halgo.Links{}.
			Self(self).
			Link("offer_maker", "/accounts/%s", op.Accountid),
		ID:          op.Offerid,
		PagingToken: op.PagingToken(),
		Account:     op.Accountid,
		TakerPays:   takerPays,
		TakerGets:   takerGets,
		Amount:      op.Amount,
		Price: PriceResource{
			N: op.Pricen,
			D: op.Priced,
		},
		PriceF: op.PriceAsFloat(),
	}

	return
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
