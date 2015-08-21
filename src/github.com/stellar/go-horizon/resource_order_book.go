package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/assets"
	"github.com/stellar/go-horizon/db"
)

// OrderBookSummaryResource is the display form of an OrderBookSummary record.
type OrderBookSummaryResource struct {
	halgo.Links
	Bids    []PriceLevelResource `json:"bids"`
	Asks    []PriceLevelResource `json:"asks"`
	Selling AssetResource        `json:"base"`
	Buying  AssetResource        `json:"counter"`
}

// PriceLevelResource is the display form of a PriceLevelRecord
type PriceLevelResource struct {
	Price  PriceResource `json:"price"`
	PriceF float64       `json:"price_f"`
	Amount int64         `json:"amount"`
}

// AssetResource is the display form of a Asset in the stellar network
type AssetResource struct {
	AssetType   string `json:"asset_type"`
	AssetCode   string `json:"asset_code,ignoreempty"`
	AssetIssuer string `json:"asset_issuer,ignoreempty"`
}

// NewOrderBookSummaryResource converts the provided query and summary into a json object
// that can be displayed to the end user.
func NewOrderBookSummaryResource(query db.OrderBookSummaryQuery, summary db.OrderBookSummaryRecord) (result OrderBookSummaryResource, err error) {
	bt, err := assets.String(query.SellingType)
	if err != nil {
		return
	}

	ct, err := assets.String(query.BuyingType)
	if err != nil {
		return
	}

	result = OrderBookSummaryResource{
		Bids: newPriceLevelResources(summary.Bids()),
		Asks: newPriceLevelResources(summary.Bids()),
		Selling: AssetResource{
			AssetType:   bt,
			AssetCode:   query.SellingCode,
			AssetIssuer: query.SellingIssuer,
		},
		Buying: AssetResource{
			AssetType:   ct,
			AssetCode:   query.BuyingCode,
			AssetIssuer: query.BuyingIssuer,
		},
	}

	return
}

func newPriceLevelResources(records []db.PriceLevelRecord) []PriceLevelResource {
	result := make([]PriceLevelResource, len(records))

	for i, rec := range records {
		result[i] = PriceLevelResource{
			PriceF: rec.Pricef,
			Price: PriceResource{
				N: rec.Pricen,
				D: rec.Priced,
			},
		}
	}

	return result
}
