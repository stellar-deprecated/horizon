package horizon

import (
	"encoding/json"
	"testing"

	"github.com/stellar/horizon/resource"
)

func TestAccountActions_Show(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	// existing account
	w := ht.Get(
		"/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	)
	if ht.Assert.Equal(200, w.Code) {

		var result resource.Account
		err := json.Unmarshal(w.Body.Bytes(), &result)
		ht.Require.NoError(err)
		ht.Assert.Equal("3", result.Sequence)
	}

	// missing account
	w = ht.Get("/accounts/100")
	ht.Assert.Equal(404, w.Code)
}

func TestAccountActions_ShowRegressions(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	w := ht.Get(
		"/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	)
	var result resource.Account
	err := json.Unmarshal(w.Body.Bytes(), &result)
	ht.Require.NoError(err)

	// Regression: no trades link
	ht.Assert.Contains(result.Links.Trades.Href, "/trades")

	// Regression: no data link
	ht.Assert.Contains(result.Links.Data.Href, "/data/{key}")
	ht.Assert.True(result.Links.Data.Templated)

	// Regression:  return 200 ok even when the history record cannot be found.

	// overwrite history with blank
	ht.T.ScenarioWithoutHorizon("base")
	w = ht.Get(
		"/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	)
	ht.Assert.Equal(200, w.Code)

}
