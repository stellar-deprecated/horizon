package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/render/hal"
	"net/http"
)

type RootResource struct {
	halgo.Links
}

var globalRootResource RootResource

func init() {
	links := halgo.Links{}.
		Self("/").
		Link("account", "/accounts/{address}").
		Link("account_transactions", "/accounts/{address}/transactions{?cursor}{?limit}{?order}").
		Link("transaction", "/transactions/{hash}").
		Link("transactions", "/transactions{?cursor}{?limit}{?order}").
		Link("metrics", "/metrics").
		Link("friendbot", "/friendbot{?addr}")

	globalRootResource = RootResource{
		Links: links,
	}
}

func rootAction(w http.ResponseWriter, r *http.Request) {
	hal.Render(w, globalRootResource)
}
