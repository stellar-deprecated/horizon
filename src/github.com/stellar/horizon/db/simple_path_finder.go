package db

import (
	"bytes"
	"fmt"
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/log"
	"github.com/stellar/horizon/paths"
	"golang.org/x/net/context"
)

// SimplePathFinder implements the paths.Finder interface and searchs for
// payment paths using a simple breadth first search of the offers table of a stellar-core.
//
// This implementation is not meant to be fast or to provide the lowest costs paths, but
// rather is meant to be a simple implementation that gives usable paths.
type SimplePathFinder struct {
	SqlQuery
	Ctx context.Context
}

// ensure SimplePathFinder is paths.Finder compliant
var _ paths.Finder = &SimplePathFinder{}

func (f *SimplePathFinder) Find(q paths.Query) (result []paths.Path, err error) {
	log.WithField(f.Ctx, "source_assets", q.SourceAssets).
		WithField("destination_asset", q.DestinationAsset).
		WithField("destination_amount", q.DestinationAmount).
		Info("Starting pathfind")

	if len(q.SourceAssets) == 0 {
		err = errors.New("No source assets")
		return
	}

	var minDepth xdr.Int64
	minDepth, err = amount.Parse(q.DestinationAmount)

	next := []*pathNode{&pathNode{q.DestinationAsset, nil}}

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
		q := AssetsWithDepthQuery{f.SqlQuery, cur.Asset, int64(minDepth)}
		err = Select(f.Ctx, q, &connected)

		if err != nil {
			return
		}

		for _, a := range connected {
			next = append(next, &pathNode{a, cur})
		}
	}

	log.WithField(f.Ctx, "found", len(result)).Info("Finished pathfind")
	return
}

type pathNode struct {
	Asset xdr.Asset
	Tail  *pathNode
}

func (p *pathNode) String() string {
	if p == nil {
		return ""
	}

	var out bytes.Buffer
	fmt.Fprintf(&out, "%v", p.Asset)

	cur := p.Tail

	for cur != nil {
		fmt.Fprintf(&out, " -> %v", cur.Asset)
		cur = cur.Tail
	}

	return out.String()
}

func (p *pathNode) Source() xdr.Asset {
	cur := p
	for cur.Tail != nil {
		cur = cur.Tail
	}
	return cur.Asset
}

func (p *pathNode) Destination() xdr.Asset {
	// the destination for path is the head of the linked list
	return p.Asset
}

func (p *pathNode) Path() []xdr.Asset {
	path := p.Flatten()

	if len(path) < 2 {
		return nil
	}

	// return the flattened slice without the first and last elements
	// which are the source and the destination assets
	return path[1 : len(path)-1]
}

func (p *pathNode) Depth() int {
	depth := 0
	cur := p
	for {
		if cur == nil {
			return depth
		}
		cur = cur.Tail
		depth++
	}
}

func (p *pathNode) Flatten() (result []xdr.Asset) {
	cur := p

	for {
		if cur == nil {
			return
		}
		result = append(result, cur.Asset)
		cur = cur.Tail
	}

	return
}
