package horizon

import (
	"net/url"
	"testing"
)

func TestTradeActions_Index(t *testing.T) {
	ht := StartHTTPTest(t, "trades")
	defer ht.Finish()

	// for an account
	w := ht.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/trades")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	// for order book
	var q = make(url.Values)
	q.Add("selling_asset_type", "credit_alphanum4")
	q.Add("selling_asset_code", "EUR")
	q.Add("selling_asset_issuer", "GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG")
	q.Add("buying_asset_type", "credit_alphanum4")
	q.Add("buying_asset_code", "USD")
	q.Add("buying_asset_issuer", "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")

	w = ht.Get("/order_book/trades?" + q.Encode())
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}
}
