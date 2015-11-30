package simplepath

import (
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/paths"
)

// search represents a single query against the simple finder.  It provides
// a place to store the results of the query, mostly for the purposes of code
// clarity.
//
// The search struct is used as follows:
//
// 1.  Create an instance, ensuring the Query and Finder fields are set
// 2.  Call Init() to populate dependent fields in the struct with their initial values
// 3.  Call Run() to perform the search.
//
type search struct {
	Query  paths.Query
	Finder *Finder

	// Fields below are initialized by a call to Init() after
	// setting the fields above
	queue   []*pathNode
	targets map[string]bool
	visited map[string]bool

	//This fields below are initialized after the search is run
	Err     error
	Results []paths.Path
}

// Init initialized the search, setting fields on the struct used to
// hold state needed during the actual search.
func (s *search) Init() {
	s.queue = []*pathNode{
		&pathNode{
			Asset: s.Query.DestinationAsset,
			Tail:  nil,
			DB:    s.Finder.SqlQuery,
		},
	}

	// build a map of asset's string representation to check if a given node
	// is one of the targets for our search.  Unfortunately, xdr.Asset is not suitable
	// for use as a map key, and so we use its string representation.
	s.targets = map[string]bool{}
	for _, a := range s.Query.SourceAssets {
		s.targets[a.String()] = true
	}

	s.visited = map[string]bool{}
	s.Err = nil
	s.Results = nil
}

// Run triggers the search, which will populate the Results and Err
// field for the search after completion.
func (s *search) Run() {
	if s.Err != nil {
		return
	}

	for s.hasMore() {
		s.runOnce()
	}
}

// pop removes the head from the search queue, returning it to the caller
func (s *search) pop() *pathNode {
	next := s.queue[0]
	s.queue = s.queue[1:]
	return next
}

// returns false if the search should stop.
func (s *search) hasMore() bool {
	if s.Err != nil {
		return false
	}

	if len(s.Results) > 4 {
		return false
	}

	return len(s.queue) > 0
}

// isTarget returns true if the asset id provided is one of the targets
// for this search (i.e. one of the requesting account's trusted assets)
func (s *search) isTarget(id string) bool {
	_, found := s.targets[id]
	return found
}

// visit returns true if the asset id provided has not been
// visited on this search, after marking the id as visited
func (s *search) visit(id string) bool {
	if _, found := s.visited[id]; found {
		return false
	}

	s.visited[id] = true
	return true
}

// runOnce processes the head of the search queue, findings results
// and extending the search as necessary.
func (s *search) runOnce() {
	cur := s.pop()
	id := cur.Asset.String()

	if s.isTarget(id) {
		s.Results = append(s.Results, cur)
	}

	if !s.visit(id) {
		return
	}

	// A PathPaymentOp's path cannot be over 5 elements in length, and so
	// we abort our search if the current linked list is over 7 (since the list
	// includes both source and destination in addition to the path)
	if cur.Depth() > 7 {
		return
	}

	s.extendSearch(cur)

}

func (s *search) extendSearch(cur *pathNode) {
	// find connected assets
	var connected []xdr.Asset
	q := db.ConnectedAssetsQuery{s.Finder.SqlQuery, cur.Asset}
	s.Err = db.Select(s.Finder.Ctx, q, &connected)
	if s.Err != nil {
		return
	}

	for _, a := range connected {
		newPath := &pathNode{
			Asset: a,
			Tail:  cur,
			DB:    s.Finder.SqlQuery,
		}

		var hasEnough bool
		hasEnough, s.Err = s.hasEnoughDepth(newPath)
		if s.Err != nil {
			return
		}

		if !hasEnough {
			continue
		}

		s.queue = append(s.queue, newPath)
	}
}

func (s *search) hasEnoughDepth(path *pathNode) (bool, error) {
	_, err := path.Cost(s.Query.DestinationAmount)
	if err == ErrNotEnough {
		return false, nil
	}
	return true, err
}
