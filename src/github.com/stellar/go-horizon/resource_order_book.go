package horizon

import (
	_ "database/sql"
	_ "fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/assets"
	"github.com/stellar/go-horizon/db"
	_ "github.com/stellar/go-horizon/render/hal"
	_ "github.com/stellar/go-stellar-base/xdr"
)

// OrderBookSummaryResource is the display form of an OrderBookSummary record.
type OrderBookSummaryResource struct {
	halgo.Links
	Bids    []PriceLevelResource `json:"bids"`
	Asks    []PriceLevelResource `json:"asks"`
	Base    AssetResource        `json:"base"`
	Counter AssetResource        `json:"counter"`
}

type PriceLevelResource struct {
	Price  PriceResource `json:"price"`
	PriceF float64       `json:"price_f"`
	Amount int64         `json:"amount"`
}

type AssetResource struct {
	AssetType   string `json:"asset_type"`
	AssetCode   string `json:"asset_code,ignoreempty"`
	AssetIssuer string `json:"asset_issuer,ignoreempty"`
}

func NewOrderBookSummaryResource(query db.OrderBookSummaryQuery, summary db.OrderBookSummaryRecord) (result OrderBookSummaryResource, err error) {
	bt, err := assets.String(query.BaseType)
	if err != nil {
		return
	}

	ct, err := assets.String(query.CounterType)
	if err != nil {
		return
	}

	result = OrderBookSummaryResource{
		Bids: offersToPriceLevels(summary.Bids, true),
		Asks: offersToPriceLevels(summary.Asks, false),
		Base: AssetResource{
			AssetType:   bt,
			AssetCode:   query.BaseCode,
			AssetIssuer: query.BaseIssuer,
		},
		Counter: AssetResource{
			AssetType:   ct,
			AssetCode:   query.CounterCode,
			AssetIssuer: query.CounterIssuer,
		},
	}

	return
}

// offersToPriceLevels collapses an array of offers into an array of PriceLevelResource objects.
// offers at the same price are collapsed into a single "Price Level"
func offersToPriceLevels(offers []db.CoreOfferRecord, bids bool) (result []PriceLevelResource) {
	result = []PriceLevelResource{}
	var current PriceLevelResource

	for _, o := range offers {

		// if accumulator holds some amount and the price is different than the current iteration
		// finish the accumulator by adding it onto the result then reset
		if current.Amount != 0 && o.PriceAsFloat() != current.PriceF {
			result = append(result, current)
			current = PriceLevelResource{}
		}

		current.Amount += o.Amount

		if bids {
			// bids should be priced as the inversion of an offer, since all offers are technically asks
			current.PriceF = 1.0 / o.PriceAsFloat()
			current.Price = PriceResource{
				N: o.Priced,
				D: o.Pricen,
			}
		} else {
			current.PriceF = o.PriceAsFloat()
			current.Price = PriceResource{
				N: o.Pricen,
				D: o.Priced,
			}
		}

	}

	if current.Amount != 0 {
		result = append(result, current)
	}

	return
}
