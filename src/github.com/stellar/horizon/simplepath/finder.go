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

	minDepth := q.DestinationAmount

	next := []*pathNode{
		&pathNode{
			Asset: q.DestinationAsset,
			Tail:  nil,
			DB:    f.SqlQuery,
		},
	}

	// build a map of asset's string representation to check if a given node
	// is one of the targets for our search.  Unfortunately, xdr.Asset is not suitable
	// for use as a map key, and so we use its string representation.
	targets := map[string]bool{}
	for _, a := range q.SourceAssets {
		targets[a.String()] = true
	}

	visited := map[string]bool{}

	for len(next) > 0 {
		cur := next[0]
		next = next[1:]
		id := cur.Asset.String()

		if _, found := targets[id]; found {
			result = append(result, cur)
			// stop searching if we've found 4 paths
			if len(result) >= 4 {
				return
			}
			continue
		}

		if _, found := visited[id]; found {
			continue
		}
		visited[id] = true

		// A PathPaymentOp's path cannot be over 5 elements in length, and so
		// we abort our search if the current linked list is over 7 (since the list
		// includes both source and destination in addition to the path)
		if cur.Depth() > 7 {
			continue
		}

		var connected []xdr.Asset
		q := db.ConnectedAssetsQuery{f.SqlQuery, cur.Asset}
		err = db.Select(f.Ctx, q, &connected)
		if err != nil {
			return
		}

		var newPaths []*pathNode
		newPaths, err = f.extendPaths(cur, connected, minDepth)
		if err != nil {
			return
		}

		next = append(next, newPaths...)
	}

	log.WithField(f.Ctx, "found", len(result)).Info("Finished pathfind")
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
