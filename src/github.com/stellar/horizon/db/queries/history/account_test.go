package history

import (
	_ "github.com/lib/pq"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestLatestAccountByAddress(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	var found int64
	q := LatestAccountForAddress{
		DB:      tt.HorizonQuery(),
		Address: "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
	}

	err := db.Get(tt.Ctx, &q, &found)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(found, int64(1))
	}

	// Missing row
	q.Address = "not_real"
	err = db.Get(tt.Ctx, &q, &found)
	tt.Assert.Equal(db.ErrNoResults, err)
}
