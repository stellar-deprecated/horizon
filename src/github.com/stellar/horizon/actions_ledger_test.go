package horizon

import (
	"encoding/json"
	"testing"

	"github.com/stellar/horizon/resource"
	"github.com/stellar/horizon/test"
)

func TestLedgerActions_Index(t *testing.T) {
	app, tt, rh := StartHTTPTest(t, "base")
	defer FinishHTTPTest(app, tt)

	// default params
	w := rh.Get("/ledgers", test.RequestHelperNoop)

	if tt.Assert.Equal(200, w.Code) {
		var result map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &result)
		tt.Require.NoError(err)

		embedded := result["_embedded"].(map[string]interface{})
		records := embedded["records"].([]interface{})
		tt.Assert.Len(records, 3)
	}

	// with limit
	w = rh.Get("/ledgers?limit=1", test.RequestHelperNoop)
	if tt.Assert.Equal(200, w.Code) {
		var result map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &result)
		tt.Require.NoError(err)

		embedded := result["_embedded"].(map[string]interface{})
		records := embedded["records"].([]interface{})
		tt.Assert.Len(records, 1)
	}
}

func TestLedgerActions_Show(t *testing.T) {
	app, tt, rh := StartHTTPTest(t, "base")
	defer FinishHTTPTest(app, tt)

	w := rh.Get("/ledgers/1", test.RequestHelperNoop)
	tt.Assert.Equal(200, w.Code)

	var result resource.Ledger
	err := json.Unmarshal(w.Body.Bytes(), &result)
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int32(1), result.Sequence)
	}

	// ledger higher than history
	w = rh.Get("/ledgers/100", test.RequestHelperNoop)
	tt.Assert.Equal(404, w.Code)

	// ledger that was reaped
	app.reaper.RetentionCount = 1
	err = app.DeleteUnretainedHistory()
	tt.Require.NoError(err)
	app.UpdateLedgerState()

	w = rh.Get("/ledgers/1", test.RequestHelperNoop)
	tt.Assert.Equal(410, w.Code)

}
