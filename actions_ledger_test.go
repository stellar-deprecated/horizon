package horizon

import (
	"encoding/json"
	"testing"

	"github.com/stellar/horizon/pkg/resource"
)

func TestLedgerActions_Index(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	// default params
	w := ht.Get("/ledgers")

	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(3, w.Body)
	}

	// with limit
	w = ht.RH.Get("/ledgers?limit=1")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}
}

func TestLedgerActions_Show(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	w := ht.Get("/ledgers/1")
	ht.Assert.Equal(200, w.Code)

	var result resource.Ledger
	err := json.Unmarshal(w.Body.Bytes(), &result)
	if ht.Assert.NoError(err) {
		ht.Assert.Equal(int32(1), result.Sequence)
	}

	// ledger higher than history
	w = ht.Get("/ledgers/100")
	ht.Assert.Equal(404, w.Code)

	// ledger that was reaped
	ht.ReapHistory(1)

	w = ht.Get("/ledgers/1")
	ht.Assert.Equal(410, w.Code)
}
