package horizon

import (
	"net/url"
	"testing"
	"time"

	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/resource"
)

func TestTradeActions_Index(t *testing.T) {
	ht := StartHTTPTest(t, "trades")
	defer ht.Finish()

	// All trades
	w := ht.Get("/trades")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	// 	ensure created_at is populated correctly
	records := []resource.Trade{}
	ht.UnmarshalPage(w.Body, &records)

	l := history.Ledger{}
	hq := history.Q{Session: ht.HorizonSession()}
	ht.Require.NoError(hq.LedgerBySequence(&l, 6))

	ht.Assert.WithinDuration(l.ClosedAt, records[0].LedgerCloseTime, 1*time.Second)

	// For offer
	w = ht.Get("/offers/1/trades")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	w = ht.Get("/offers/2/trades")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(0, w.Body)
	}

	// for an account
	w = ht.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/trades")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	w = ht.Get("/accounts/GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU/trades")
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

		records := []map[string]interface{}{}
		ht.UnmarshalPage(w.Body, &records)

		ht.Assert.Contains(records[0], "bought_amount")
		ht.Assert.Contains(records[0], "sold_amount")
	}

	// asset filter
	q = make(url.Values)
	q.Add("sold_asset_type", "credit_alphanum4")
	q.Add("sold_asset_code", "EUR")
	q.Add("sold_asset_issuer", "GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG")
	q.Add("bought_asset_type", "credit_alphanum4")
	q.Add("bought_asset_code", "USD")
	q.Add("bought_asset_issuer", "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4")

	w = ht.Get("/trades?" + q.Encode())
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}
}

func TestTradeActions_IndexRegressions(t *testing.T) {
	ht := StartHTTPTest(t, "trades")
	defer ht.Finish()

	// Regression:  https://github.com/stellar/horizon/issues/318
	var q = make(url.Values)
	q.Add("selling_asset_type", "credit_alphanum4")
	q.Add("selling_asset_code", "EUR")
	q.Add("selling_asset_issuer", "GCQPYGH4K57XBDENKKX55KDTWOTK5WDWRQOH2LHEDX3EKVIQRLMESGBG")
	q.Add("buying_asset_type", "native")

	w := ht.Get("/order_book/trades?" + q.Encode())
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(0, w.Body)
	}
}
