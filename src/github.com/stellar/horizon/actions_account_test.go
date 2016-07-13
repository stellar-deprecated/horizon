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
