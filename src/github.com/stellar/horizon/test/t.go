package test

import (
	"github.com/stellar/horizon/db2"
	"github.com/stellar/horizon/ledger"
)

// CoreRepo returns a db2.Repo instance pointing at the stellar core test database
func (t *T) CoreRepo() *db2.Repo {
	return &db2.Repo{
		DB:  t.CoreDB,
		Ctx: t.Ctx,
	}
}

// Finish finishes the test, logging any accumulated horizon logs to the logs
// output
func (t *T) Finish() {
	RestoreLogger()
	// Reset cached ledger state
	ledger.SetState(ledger.State{})

	if t.LogBuffer.Len() > 0 {
		t.T.Log("\n" + t.LogBuffer.String())
	}
}

// HorizonRepo returns a db2.Repo instance pointing at the horizon test database
func (t *T) HorizonRepo() *db2.Repo {
	return &db2.Repo{
		DB:  t.HorizonDB,
		Ctx: t.Ctx,
	}
}

// Scenario loads the named sql scenario into the database
func (t *T) Scenario(name string) *T {
	LoadScenario(name)
	return t
}

// ScenarioWithoutHorizon loads the named sql scenario into the database
func (t *T) ScenarioWithoutHorizon(name string) *T {
	LoadScenarioWithoutHorizon(name)
	return t
}

// UpdateLedgerState updates the cached ledger state (or panicing on failure).
func (t *T) UpdateLedgerState() {
	var next ledger.State

	err := t.CoreRepo().GetRaw(&next, `
		SELECT
			MIN(ledgerseq) as core_elder,
			MAX(ledgerseq) as core_latest
		FROM ledgerheaders
	`)

	if err != nil {
		panic(err)
	}

	err = t.HorizonRepo().GetRaw(&next, `
			SELECT
				MIN(sequence) as horizon_elder,
				MAX(sequence) as horizon_latest
			FROM history_ledgers
		`)

	if err != nil {
		panic(err)
	}

	ledger.SetState(next)
	return
}
