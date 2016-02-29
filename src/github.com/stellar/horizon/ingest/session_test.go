package ingest

import (
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/horizon/db"
	hq "github.com/stellar/horizon/db/queries/history"
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestIngestBaseScenario(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("base")
	defer tt.Finish()

	i := New(
		network.TestNetworkPassphrase,
		db.SqlQuery{tt.CoreDB},
		db.SqlQuery{tt.HorizonDB},
	)
	s := &Session{
		Ingester:    i,
		FirstLedger: 1,
		LastLedger:  3,
	}

	s.Run()
	tt.Require.NoError(s.Err)

	tt.Assert.Equal(3, s.Ingested)

	// Ensure the root account was created
	var root history.Account
	err := db.Get(tt.Ctx, &hq.AccountByID{
		DB: db.SqlQuery{tt.HorizonDB},
		ID: 1,
	}, &root)
	tt.Assert.NoError(err)
	tt.Assert.Equal(int64(1), root.ID)
	tt.Assert.Equal(keypair.Master(i.Network).Address(), root.Address)

	// Test that re-importing fails
	s.Err = nil
	s.Run()
	tt.Require.Error(s.Err, "Reimport didn't fail as expected")

	// Test that re-importing fails with allowing clear succeeds
	s.Err = nil
	s.ClearExisting = true
	s.Run()
	tt.Require.NoError(s.Err, "Couldn't re-import, even with clear allowed")

}
