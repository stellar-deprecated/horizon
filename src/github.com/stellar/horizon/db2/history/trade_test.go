package history

import (
	"testing"

	"github.com/stellar/go/build"
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/test"
)

func TestTradeQueries(t *testing.T) {
	tt := test.Start(t).Scenario("kahuna")
	defer tt.Finish()
	q := &Q{tt.HorizonSession()}
	var trades []Trade

	// All trades
	err := q.Trades().Select(&trades)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(trades, 4)
	}

	// Paging
	pq := db2.MustPageQuery(trades[0].PagingToken(), "asc", 1)
	var pt []Trade

	err = q.Trades().Page(pq).Select(&pt)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(pt, 1)
		tt.Assert.Equal(trades[1], pt[0])
	}

	// Cursor bounds checking
	pq = db2.MustPageQuery("", "desc", 1)
	err = q.Trades().Page(pq).Select(&pt)
	tt.Assert.NoError(err)

	// Test ForOffer
	err = q.Trades().ForOffer(2).Select(&trades)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(trades, 2)
	}

	err = q.Trades().ForOffer(4).Select(&trades)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(trades, 0)
	}

	// Test ForSoldAsset()

	q.Trades().ForSoldAsset(build.NativeAsset().MustXDR()).Select(&trades)

	if tt.Assert.Len(trades, 2) {
		tt.Assert.Equal("native", trades[0].SoldAssetType)
		tt.Assert.Equal("", trades[0].SoldAssetIssuer)
		tt.Assert.Equal("", trades[0].SoldAssetCode)
		tt.Assert.Equal("native", trades[1].SoldAssetType)
		tt.Assert.Equal("", trades[1].SoldAssetIssuer)
		tt.Assert.Equal("", trades[1].SoldAssetCode)
	}

	// Test ForBoughtAsset

	issuer := "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"
	usd := build.CreditAsset("USD", issuer)

	q.Trades().ForBoughtAsset(usd.MustXDR()).Select(&trades)

	if tt.Assert.Len(trades, 1) {
		tt.T.Log(trades[0])
		tt.Assert.Equal("credit_alphanum4", trades[0].BoughtAssetType)
		tt.Assert.Equal(issuer, trades[0].BoughtAssetIssuer)
		tt.Assert.Equal("USD", trades[0].BoughtAssetCode)
	}
}
