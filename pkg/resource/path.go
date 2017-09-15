package resource

import (
	"github.com/stellar/go/amount"
	"github.com/stellar/horizon/pkg/paths"
	"golang.org/x/net/context"
)

func (this *Path) Populate(ctx context.Context, q paths.Query, p paths.Path) (err error) {

	this.DestinationAmount = amount.String(q.DestinationAmount)
	cost, err := p.Cost(q.DestinationAmount)
	if err != nil {
		return
	}

	this.SourceAmount = amount.String(cost)

	err = p.Source().Extract(
		&this.SourceAssetType,
		&this.SourceAssetCode,
		&this.SourceAssetIssuer)

	if err != nil {
		return
	}

	err = p.Destination().Extract(
		&this.DestinationAssetType,
		&this.DestinationAssetCode,
		&this.DestinationAssetIssuer)

	if err != nil {
		return
	}

	path := p.Path()

	this.Path = make([]Asset, len(path))

	for i, a := range path {
		err = a.Extract(
			&this.Path[i].Type,
			&this.Path[i].Code,
			&this.Path[i].Issuer)
		if err != nil {
			return
		}
	}

	return
}

// stub implementation to satisfy pageable interface
func (this Path) PagingToken() string {
	return ""
}
