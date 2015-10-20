package simplepath

import (
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/paths"
	"golang.org/x/net/context"
)

// Finder implements the paths.Finder interface and searchs for
// payment paths using a simple breadth first search of the offers table of a stellar-core.
//
// This implementation is not meant to be fast or to provide the lowest costs paths, but
// rather is meant to be a simple implementation that gives usable paths.
type Finder struct {
	db.SqlQuery
	Ctx context.Context
}

// ensure the struct is paths.Finder compliant
var _ paths.Finder = &Finder{}

func (f *Finder) Find(q paths.Query) (result []paths.Path, err error) {
	log.WithField(f.Ctx, "source_assets", q.SourceAssets).
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

	return s.Results, s.Err

	log.WithField(f.Ctx, "found", len(s.Results)).
		WithField("err", s.Err).
		Info("Finished pathfind")
	return
}

func (f *Finder) hasEnoughDepth(path *pathNode, neededAmount xdr.Int64) (bool, error) {
	_, err := path.Cost(neededAmount)
	if err == ErrNotEnough {
		return false, nil
	}
	return true, err
}

func (f *Finder) extendPaths(cur *pathNode,
	connected []xdr.Asset,
	neededAmount xdr.Int64) (results []*pathNode, err error) {

	for _, a := range connected {
		newPath := &pathNode{
			Asset: a,
			Tail:  cur,
			DB:    f.SqlQuery,
		}

		var hasEnough bool
		hasEnough, err = f.hasEnoughDepth(newPath, neededAmount)
		if err != nil {
			return
		}

		if !hasEnough {
			continue
		}

		results = append(results, newPath)
	}
	return
}
