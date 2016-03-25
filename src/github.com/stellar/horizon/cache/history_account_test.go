package cache

import (
	"github.com/stellar/horizon/test"
	"testing"
)

func TestHistoryAccount(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	db := tt.HorizonRepo()
	c := NewHistoryAccount(db)
	tt.Assert.Equal(0, c.cached.Len())

	id, err := c.Get("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H")
	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int64(1), id)
		tt.Assert.Equal(1, c.cached.Len())
	}

	id, err = c.Get("NOT_REAL")
	tt.Assert.True(db.NoRows(err))
	tt.Assert.Equal(int64(0), id)
}
