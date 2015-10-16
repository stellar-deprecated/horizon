package paths

import (
	"github.com/stellar/go-stellar-base/xdr"
)

type DummyFinder struct {
}

func (f *DummyFinder) Find(q Query) ([]Path, error) {
	paths := make([]Path, 2)
	n, err := xdr.NewAsset(xdr.AssetTypeAssetTypeNative, nil)

	if err != nil {
		return nil, err
	}

	paths[0] = DummyPath{
		source:      n,
		destination: n,
		path:        []xdr.Asset{n, n, n},
	}

	paths[1] = DummyPath{
		source:      n,
		destination: n,
		path:        []xdr.Asset{n, n, n},
	}

	return paths, nil
}

type DummyPath struct {
	source      xdr.Asset
	destination xdr.Asset
	path        []xdr.Asset
}

func (d DummyPath) Source() xdr.Asset               { return d.source }
func (d DummyPath) Destination() xdr.Asset          { return d.destination }
func (d DummyPath) Path() []xdr.Asset               { return d.path }
func (d DummyPath) Cost(amount xdr.Int64) xdr.Int64 { return amount }
