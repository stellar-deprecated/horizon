package horizon

import (
	"github.com/jagregory/halgo"
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

	renderHAL(w, root)
}
