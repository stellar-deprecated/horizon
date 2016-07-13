package ingest

import (
	"testing"

	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/horizon/test"
)

func TestIngest(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()

	s := ingest(tt)
	tt.Require.NoError(s.Err)
	tt.Assert.Equal(59, s.Ingested)

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

func ingest(tt *test.T) *Session {
	s, _ := RunOnce(
		network.TestNetworkPassphrase,
		"",
		tt.CoreRepo(),
		tt.HorizonRepo(),
	)
	return s
}
