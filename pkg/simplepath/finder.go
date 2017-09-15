package simplepath

import (
	"github.com/go-errors/errors"
	"github.com/stellar/horizon/pkg/db2/core"
	"github.com/stellar/horizon/pkg/log"
	"github.com/stellar/horizon/pkg/paths"
)

// Finder implements the paths.Finder interface and searchs for
// payment paths using a simple breadth first search of the offers table of a stellar-core.
//
// This implementation is not meant to be fast or to provide the lowest costs paths, but
// rather is meant to be a simple implementation that gives usable paths.
type Finder struct {
	Q *core.Q
}

// ensure the struct is paths.Finder compliant
var _ paths.Finder = &Finder{}

// Find performs a path find with the provided query.
func (f *Finder) Find(q paths.Query) (result []paths.Path, err error) {
	log.WithField("source_assets", q.SourceAssets).
		WithField("destination_asset", q.DestinationAsset).
		WithField("destination_amount", q.DestinationAmount).
		Info("Starting pathfind")

	if len(q.SourceAssets) == 0 {
		err = errors.New("No source assets")
		return
	}

	s := &search{
		Query:  q,
		Finder: f,
	}

	s.Init()
	s.Run()

	result, err = s.Results, s.Err

	log.WithField("found", len(s.Results)).
		WithField("err", s.Err).
		Info("Finished pathfind")
	return
}
