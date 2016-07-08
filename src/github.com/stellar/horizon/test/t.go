package test

import (
	"github.com/stellar/horizon/db2"
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
