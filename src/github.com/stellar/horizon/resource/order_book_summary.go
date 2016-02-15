package resource

import (
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db/records/core"
	"golang.org/x/net/context"
)

func (this *OrderBookSummary) Populate(ctx context.Context, query *db.OrderBookSummaryQuery, row core.OrderBookSummary) error {

	st, err := assets.String(query.SellingType)
	if err != nil {
		return err
	}

	bt, err := assets.String(query.BuyingType)
	if err != nil {
		return err
	}

	this.Selling = Asset{
		Type:   st,
		Code:   query.SellingCode,
		Issuer: query.SellingIssuer,
	}
	this.Buying = Asset{
		Type:   bt,
		Code:   query.BuyingCode,
		Issuer: query.BuyingIssuer,
	}

	this.populateLevels(&this.Bids, row.Bids())
	this.populateLevels(&this.Asks, row.Asks())

	return nil
}

func (this *OrderBookSummary) populateLevels(destp *[]PriceLevel, rows []core.OrderBookSummaryPriceLevel) {
	*destp = make([]PriceLevel, len(rows))
	dest := *destp

	for i, row := range rows {
		dest[i] = PriceLevel{
			Price:  row.PriceAsString(),
			Amount: row.AmountAsString(),
			PriceR: Price{
				N: row.Pricen,
				D: row.Priced,
			},
		}
	}
}
