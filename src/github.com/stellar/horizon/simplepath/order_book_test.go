package simplepath

import (
	"testing"

	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/test"
)

func TestOrderBook(t *testing.T) {
	tt := test.Start(t).Scenario("paths")
	defer tt.Finish()

	ob := orderBook{
		Selling: makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"EUR",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
		Buying: makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"USD",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
		Q: &core.Q{Repo: tt.CoreRepo()},
	}

	r, err := ob.Cost(ob.Buying, 10000000)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(xdr.Int64(10000000), r)
	}

	// this cost should consume the entire lowest priced order, whose price
	// is 1.0, thus the output should be the same
	r, err = ob.Cost(ob.Buying, 100000000)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(xdr.Int64(100000000), r)
	}

	// now we are taking from the next offer, where the price is 2.0
	r, err = ob.Cost(ob.Buying, 100000001)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(xdr.Int64(100000002), r)
	}

	r, err = ob.Cost(ob.Buying, 500000000)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(xdr.Int64(900000000), r)
	}

	_, err = ob.Cost(ob.Buying, 500000001)
	tt.Assert.Error(err)

}

func TestOrderBook_BadCost(t *testing.T) {
	tt := test.Start(t).Scenario("bad_cost")
	defer tt.Finish()

	ob := orderBook{
		Selling: makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"EUR",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
		Buying: makeAsset(
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"USD",
			"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"),
		Q: &core.Q{Repo: tt.CoreRepo()},
	}

	r, err := ob.Cost(ob.Buying, 10000000)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(xdr.Int64(2000000000), r)
	}
}
