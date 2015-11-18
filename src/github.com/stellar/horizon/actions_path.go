package horizon

import (
	"github.com/stellar/horizon/db"
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
		action.LoadQuery,
		action.LoadSourceAssets,
		action.LoadRecords,
		action.LoadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// LoadQuery builds the path finding query based upon the request parameters.
func (action *PathIndexAction) LoadQuery() {
	action.Query.DestinationAmount = action.GetAmount("destination_amount")
	action.Query.DestinationAddress = action.GetAddress("destination_account")
	action.Query.DestinationAsset = action.GetAsset("destination_")

}

func (action *PathIndexAction) LoadSourceAssets() {
	q := db.AssetsForAddressQuery{
		SqlQuery: action.App.CoreQuery(),
		Address:  action.GetAddress("source_account"),
	}
	action.Err = db.Select(action.Ctx, q, &action.Query.SourceAssets)
}

// LoadRecords performs the path find and populates action.Records
func (action *PathIndexAction) LoadRecords() {
	action.Records, action.Err = action.App.paths.Find(action.Query)
}

// LoadResources converts the found records into JSON resources
func (action *PathIndexAction) LoadPage() {
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
