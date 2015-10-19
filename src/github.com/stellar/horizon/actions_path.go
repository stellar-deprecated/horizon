package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/render/hal"
)

type PathIndexAction struct {
	Action
	Query     paths.Query
	Records   []paths.Path
	Resources []interface{}
}

func (action *PathIndexAction) JSON() {
	action.Do(action.LoadQuery, action.LoadRecords, action.LoadResources)

	action.Do(func() {
		result := hal.Page{
			Links:   halgo.Links{}.Self(action.R.URL.Path),
			Records: action.Resources,
		}
		hal.Render(action.W, result)
	})
}

func (action *PathIndexAction) LoadQuery() {
	action.Query.DestinationAmount = action.GetAmount("destination_amount")
	action.Query.DestinationAddress = action.GetAddress("destination_account")
	action.Query.DestinationAsset = action.GetAsset("destination_")

	q := db.AssetsForAddressQuery{
		SqlQuery: action.App.CoreQuery(),
		Address:  action.GetAddress("source_account"),
	}

	// abort the query if an error occured, since it will be wasted work
	if action.Err != nil {
		return
	}

	action.Err = db.Select(action.Ctx, q, &action.Query.SourceAssets)
}

func (action *PathIndexAction) LoadRecords() {
	action.Records, action.Err = action.App.paths.Find(action.Query)
}

func (action *PathIndexAction) LoadResources() {
	action.Resources = make([]interface{}, len(action.Records))

	for i, p := range action.Records {
		r := &PathResource{}
		action.Err = r.Populate(action.Query, p)
		if action.Err != nil {
			return
		}
		action.Resources[i] = r
	}
}

type PathResource struct {
	SourceAssetType        string              `json:"source_asset_type"`
	SourceAssetCode        string              `json:"source_asset_code,omitempty"`
	SourceAssetIssuer      string              `json:"source_asset_issuer,omitempty"`
	SourceAmount           string              `json:"source_amount"`
	DestinationAssetType   string              `json:"destination_asset_type"`
	DestinationAssetCode   string              `json:"destination_asset_code,omitempty"`
	DestinationAssetIssuer string              `json:"destination_asset_issuer,omitempty"`
	DestinationAmount      string              `json:"destination_amount"`
	Path                   []PathAssetResource `json:"path"`
}

type PathAssetResource struct {
	Type   string `json:"asset_type"`
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"asset_issuer,omitempty"`
}

func (pr *PathResource) Populate(q paths.Query, p paths.Path) error {
	var err error

	pr.DestinationAmount = amount.String(q.DestinationAmount)
	cost, err := p.Cost(q.DestinationAmount)
	if err != nil {
		return err
	}

	pr.SourceAmount = amount.String(cost)

	err = p.Source().Extract(
		&pr.SourceAssetType,
		&pr.SourceAssetCode,
		&pr.SourceAssetIssuer)

	if err != nil {
		return err
	}

	err = p.Destination().Extract(
		&pr.DestinationAssetType,
		&pr.DestinationAssetCode,
		&pr.DestinationAssetIssuer)

	if err != nil {
		return err
	}

	path := p.Path()

	pr.Path = make([]PathAssetResource, len(path))

	for i, a := range path {
		err = a.Extract(
			&pr.Path[i].Type,
			&pr.Path[i].Code,
			&pr.Path[i].Issuer)
		if err != nil {
			return err
		}
	}

	return nil
}
