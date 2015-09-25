package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/render/hal"
)

// RootResource is the initial map of links into the api.
type RootResource struct {
	halgo.Links
	HorizonVersion     string
	StellarCoreVersion string
}

type RootAction struct {
	Action
}

func (action *RootAction) JSON() {
	var response = RootResource{
		HorizonVersion:     action.App.horizonVersion,
		StellarCoreVersion: action.App.coreVersion,
		Links: halgo.Links{}.
			Self("/").
			Link("account", "/accounts/{address}").
			Link("account_transactions", "/accounts/{address}/transactions{?cursor,limit,order}").
			Link("transaction", "/transactions/{hash}").
			Link("transactions", "/transactions{?cursor,limit,order}").
			Link("order_book", "/order_book{?selling_asset_type,selling_asset_code,selling_issuer,buying_asset_type,buying_asset_code,buying_issuer}").
			Link("metrics", "/metrics").
			Link("friendbot", "/friendbot{?addr}"),
	}
	hal.Render(action.W, response)
}
