package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
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
	Code   string `json:"currency_code"`
	Issuer string `json:"currency_issuer"`
}

// PriceResource is a price, used by offers, expressed as a fraction, N/D.
type PriceResource struct {
	N int32 `json:"numerator"`
	D int32 `json:"denominator"`
}

func (r OfferResource) SseData() interface{} { return r }
func (r OfferResource) Err() error           { return nil }
func (r OfferResource) SseId() string        { return r.PagingToken }

func offerRecordToResource(record db.Record) (result render.Resource, err error) {

	op := record.(db.CoreOfferRecord)
	self := fmt.Sprintf("/offers/%d", op.Offerid)

	result = OfferResource{
		Links: halgo.Links{}.
			Self(self).
			Link("offer_maker", "/accounts/%s", op.Accountid),
		ID:          op.Offerid,
		PagingToken: op.PagingToken(),
		Account:     op.Accountid,
		TakerPays: OfferCurrencyResource{
			Type:   "alphanum",
			Code:   op.Paysalphanumcurrency,
			Issuer: op.Paysissuer,
		},
		TakerGets: OfferCurrencyResource{
			Type:   "alphanum",
			Code:   op.Getsalphanumcurrency,
			Issuer: op.Getsissuer,
		},
		Amount: op.Amount,
		Price: PriceResource{
			N: op.Pricen,
			D: op.Priced,
		},
		PriceF: op.PriceAsFloat(),
	}

	return
}
