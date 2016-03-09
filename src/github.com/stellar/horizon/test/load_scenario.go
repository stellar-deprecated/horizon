package test

import (
	"github.com/stellar/horizon/test/scenarios"
)

func loadScenario(scenarioName string, includeHorizon bool) {
	scenarioBasePath := "scenarios/" + scenarioName
	stellarCorePath := scenarioBasePath + "-core.sql"
	horizonPath := scenarioBasePath + "-horizon.sql"

	if !includeHorizon {
		horizonPath = "scenarios/blank-horizon.sql"
	}

	scenarios.Load(StellarCoreDatabaseURL(), stellarCorePath)
	scenarios.Load(DatabaseURL(), horizonPath)
}
