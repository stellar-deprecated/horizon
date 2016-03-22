package core

import (
	"testing"

	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/test"
)

func TestGetOrderBookSummary(t *testing.T) {
	tt := test.Start(t).Scenario("order_books")
	defer tt.Finish()
	q := &Q{tt.CoreRepo()}

	selling, err := AssetFromDB(xdr.AssetTypeAssetTypeCreditAlphanum4, "USD", "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")
	tt.Require.NoError(err)
	buying, err := AssetFromDB(xdr.AssetTypeAssetTypeNative, "", "")
	tt.Require.NoError(err)

	var summary, inverted OrderBookSummary
	err = q.GetOrderBookSummary(&summary, selling, buying)
	tt.Require.NoError(err)
	tt.Require.Len(summary, 6)
	err = q.GetOrderBookSummary(&inverted, buying, selling)
	tt.Require.NoError(err)
	tt.Require.Len(inverted, 6)

	asks := summary.Asks()
	bids := summary.Bids()
	iasks := inverted.Asks()
	ibids := inverted.Bids()

	// Check that summary was loaded correct
	tt.Assert.Equal(int64(100000000), asks[0].Amount)
	tt.Assert.Equal(int32(15), asks[0].Pricen)
	tt.Assert.Equal(int32(1), asks[0].Priced)

	tt.Assert.Equal(int64(1000000000), asks[1].Amount)
	tt.Assert.Equal(int32(20), asks[1].Pricen)
	tt.Assert.Equal(int32(1), asks[1].Priced)

	tt.Assert.Equal(int64(10000000000), asks[2].Amount)
	tt.Assert.Equal(int32(50), asks[2].Pricen)
	tt.Assert.Equal(int32(1), asks[2].Priced)

	tt.Assert.Equal(int64(1000000000), bids[0].Amount)
	tt.Assert.Equal(int32(10), bids[0].Pricen)
	tt.Assert.Equal(int32(1), bids[0].Priced)

	tt.Assert.Equal(int64(9000000000), bids[1].Amount)
	tt.Assert.Equal(int32(9), bids[1].Pricen)
	tt.Assert.Equal(int32(1), bids[1].Priced)

	tt.Assert.Equal(int64(50000000000), bids[2].Amount)
	tt.Assert.Equal(int32(5), bids[2].Pricen)
	tt.Assert.Equal(int32(1), bids[2].Priced)

	// Check that the inversion was correct
	tt.Assert.Equal(asks[0].Pricef, ibids[0].InvertPricef())
	tt.Assert.Equal(asks[1].Pricef, ibids[1].InvertPricef())
	tt.Assert.Equal(asks[2].Pricef, ibids[2].InvertPricef())
	tt.Assert.Equal(bids[0].Pricef, iasks[0].InvertPricef())
	tt.Assert.Equal(bids[1].Pricef, iasks[1].InvertPricef())
	tt.Assert.Equal(bids[2].Pricef, iasks[2].InvertPricef())
}
