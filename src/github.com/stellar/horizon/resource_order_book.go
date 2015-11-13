package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/resource"
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
	PriceR resource.Price `json:"price_r"`
	Price  string         `json:"price"`
	Amount string         `json:"amount"`
}

// AssetResource is the display form of a Asset in the stellar network
type AssetResource struct {
	AssetType   string `json:"asset_type"`
	AssetCode   string `json:"asset_code,omitempty"`
	AssetIssuer string `json:"asset_issuer,omitempty"`
}

// NewOrderBookSummaryResource converts the provided query and summary into a json object
// that can be displayed to the end user.
func NewOrderBookSummaryResource(query *db.OrderBookSummaryQuery, summary db.OrderBookSummaryRecord) (result OrderBookSummaryResource, err error) {
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
		Asks: newPriceLevelResources(summary.Asks()),
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

func newPriceLevelResources(records []db.OrderBookSummaryPriceLevelRecord) []PriceLevelResource {
	result := make([]PriceLevelResource, len(records))

	for i, rec := range records {
		result[i] = PriceLevelResource{
			Price:  rec.PriceAsString(),
			Amount: rec.AmountAsString(),
			PriceR: resource.Price{
				N: rec.Pricen,
				D: rec.Priced,
			},
		}
	}

	return result
}
