package simplepath

import (
	"testing"

	"github.com/stellar/go/xdr"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/test"
)

func TestFinder(t *testing.T) {
	tt := test.Start(t).Scenario("paths")
	defer tt.Finish()

	finder := &Finder{
		Q: &core.Q{Session: tt.CoreSession()},
	}

	native := makeAsset(xdr.AssetTypeAssetTypeNative, "", "")
	usd := makeAsset(
		xdr.AssetTypeAssetTypeCreditAlphanum4,
		"USD",
		"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN")
	eur := makeAsset(
		xdr.AssetTypeAssetTypeCreditAlphanum4,
		"EUR",
		"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN")

	query := paths.Query{
		DestinationAddress: "GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V",
		DestinationAsset:   eur,
		DestinationAmount:  xdr.Int64(200000000),
		SourceAssets:       []xdr.Asset{usd},
	}

	p, err := finder.Find(query)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(p, 3)
	}

	query.DestinationAmount = xdr.Int64(200000001)
	p, err = finder.Find(query)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(p, 2)
	}

	query.DestinationAmount = xdr.Int64(500000001)
	p, err = finder.Find(query)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(p, 0)
	}

	//  regression: paths that involve native currencies can be found

	query = paths.Query{
		DestinationAddress: "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
		DestinationAsset:   native,
		DestinationAmount:  xdr.Int64(1),
		SourceAssets:       []xdr.Asset{usd, native},
	}
	p, err = finder.Find(query)
	if tt.Assert.NoError(err) {
		tt.Assert.Len(p, 2)
	}
}
