package paths

import (
	"github.com/stellar/go-stellar-base/xdr"
)

// Query is a query for paths
type Query struct {
	DestinationAddress string
	DestinationAsset   xdr.Asset
	DestinationAmount  xdr.Int64
	SourceAssets       []xdr.Asset
}

// Path is the interface that represents a single result returned
// by a path finder.
type Path interface {
	Path() []xdr.Asset
	Source() xdr.Asset
	Destination() xdr.Asset
	// Cost returns an amount (which may be estimated), delimited in the Source assets
	// that is suitable for use as the `sendMax` field for a `PathPaymentOp` struct.
	Cost(amount xdr.Int64) xdr.Int64
}

// Finder finds paths.
type Finder interface {
	Find(Query) ([]Path, error)
}
