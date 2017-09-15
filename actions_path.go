package horizon

import (
	"github.com/stellar/horizon/paths"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/resource"
)

// PathIndexAction provides path finding
type PathIndexAction struct {
	Action
	Query   paths.Query
	Records []paths.Path
	Page    hal.BasePage
}

// JSON implements actions.JSON
func (action *PathIndexAction) JSON() {
	action.Do(
		action.loadQuery,
		action.loadSourceAssets,
		action.loadRecords,
		action.loadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

func (action *PathIndexAction) loadQuery() {
	action.Query.DestinationAmount = action.GetAmount("destination_amount")
	action.Query.DestinationAddress = action.GetAddress("destination_account")
	action.Query.DestinationAsset = action.GetAsset("destination_")

}

func (action *PathIndexAction) loadSourceAssets() {
	action.Err = action.CoreQ().AssetsForAddress(
		&action.Query.SourceAssets,
		action.GetAddress("source_account"),
	)
}

func (action *PathIndexAction) loadRecords() {
	action.Records, action.Err = action.App.paths.Find(action.Query)
}

func (action *PathIndexAction) loadPage() {
	action.Page.Init()
	for _, p := range action.Records {
		var res resource.Path
		action.Err = res.Populate(action.Ctx, action.Query, p)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}
}
