package ingest

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestIngestBaseScenario(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("base")
	defer tt.Finish()

	i := New(
		db.SqlQuery{tt.CoreDB},
		db.SqlQuery{tt.HorizonDB},
	)
	s := &Session{
		Ingester:    i,
		FirstLedger: 1,
		LastLedger:  3,
	}

	s.Run()
	if tt.Assert.NoError(s.Err) {
		tt.Assert.Equal(3, s.Ingested)
	}
}
