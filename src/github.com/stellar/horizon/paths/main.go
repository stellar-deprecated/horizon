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
	return []Path{}, nil
}
