package resource

import (
	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/pkg/db2/core"
	"golang.org/x/net/context"
)

func (this *OrderBookSummary) Populate(
	ctx context.Context,
	selling xdr.Asset,
	buying xdr.Asset,
	row core.OrderBookSummary,
) error {

	err := this.Selling.Populate(ctx, selling)
	if err != nil {
		return err
	}
	err = this.Buying.Populate(ctx, buying)
	if err != nil {
		return err
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
