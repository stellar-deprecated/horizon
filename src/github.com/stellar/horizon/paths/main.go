package paths

import (
	"github.com/stellar/go-stellar-base/xdr"
)

type Query struct {
	DestinationAddress string
	DestinationAsset   xdr.Asset
	DestinationAmount  string
	SourceAssets       []xdr.Asset
}

type Path interface {
	Path() []xdr.Asset
	Source() xdr.Asset
	Destination() xdr.Asset
}

type Finder interface {
	Find(Query) ([]Path, error)
}

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

func (d DummyPath) Source() xdr.Asset      { return d.source }
func (d DummyPath) Destination() xdr.Asset { return d.destination }
func (d DummyPath) Path() []xdr.Asset      { return d.path }
