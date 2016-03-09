package test

import (
	"github.com/stellar/horizon/db"
)

// CoreQuery returns a `db.SqlQuery` that loads from stellar core's db
func (t *T) CoreQuery() db.SqlQuery {
	return db.SqlQuery{DB: t.CoreDB}
}

// Finish finishes the test, logging any accumulated horizon logs to the logs
// output
func (t *T) Finish() {
	if t.LogBuffer.Len() > 0 {
		t.T.Log("\n" + t.LogBuffer.String())
	}
}

// HorizonQuery returns a `db.SqlQuery` that loads from horizon's db
func (t *T) HorizonQuery() db.SqlQuery {
	return db.SqlQuery{DB: t.HorizonDB}
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
