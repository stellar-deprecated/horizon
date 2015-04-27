package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/hal"
	"net/http"
)

func rootAction(w http.ResponseWriter, r *http.Request) {
	root := halgo.Links{}.
		Self("/").
		Link("account", "/accounts/{address}").
		Link("account_transactions", "/accounts/{address}/transactions{?after}{?limit}{?order}").
		Link("transaction", "/transactions/{hash}").
		Link("transactions", "/transactions{?after}{?limit}{?order}").
		Link("metrics", "/metrics").
		Link("friendbot", "/friendbot{?addr}")

	hal.Render(w, root)
}
