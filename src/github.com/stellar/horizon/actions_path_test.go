package horizon

import (
	"net/url"
	"testing"
)

func TestPathActions_Index(t *testing.T) {
	ht := StartHTTPTest(t, "paths")
	defer ht.Finish()

	// no query args
	w := ht.Get("/paths")
	ht.Assert.Equal(400, w.Code)

	// happy path
	var q = make(url.Values)

	q.Add(
		"destination_account",
		"GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V",
	)
	q.Add(
		"source_account",
		"GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP",
	)
	q.Add(
		"destination_asset_issuer",
		"GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN",
	)
	q.Add("destination_asset_type", "credit_alphanum4")
	q.Add("destination_asset_code", "EUR")
	q.Add("destination_amount", "10")

	w = ht.Get("/paths?" + q.Encode())
	ht.Assert.Equal(200, w.Code)
	ht.Assert.PageOf(3, w.Body)

}
