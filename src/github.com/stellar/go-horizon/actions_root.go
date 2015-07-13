package horizon

import (
	"net/http"

	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/render/hal"
)

// RootResource is the initial map of links into the api.
type RootResource struct {
	halgo.Links
}

var globalRootResource = RootResource{
	Links: halgo.Links{}.
		Self("/").
		Link("account", "/accounts/{address}").
		Link("account_transactions", "/accounts/{address}/transactions{?cursor,limit,order}").
		Link("transaction", "/transactions/{hash}").
		Link("transactions", "/transactions{?cursor,limit,order}").
		Link("orderbook", "/orderbooks{?base_type,base_code,base_issuer,counter_type,counter_code,counter_issuer}").
		Link("metrics", "/metrics").
		Link("friendbot", "/friendbot{?addr}"),
}

func rootAction(w http.ResponseWriter, r *http.Request) {
	hal.Render(w, globalRootResource)
}
