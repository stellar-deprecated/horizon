package test

import (
	"bytes"
	"log"
	"os/exec"
)

func loadScenario(scenarioName string, includeHorizon bool) {
	scenarioBasePath := "scenarios/" + scenarioName
	stellarCorePath := scenarioBasePath + "-core.sql"
	horizonPath := scenarioBasePath + "-horizon.sql"

	if !includeHorizon {
		horizonPath = "scenarios/blank-horizon.sql"
	}

	loadSQLFile(StellarCoreDatabaseURL(), stellarCorePath)
	loadSQLFile(DatabaseURL(), horizonPath)
}

func loadSQLFile(url string, path string) {
	sql, err := Asset(path)

	if err != nil {
		log.Panic(err)
	}

	reader := bytes.NewReader(sql)
	cmd := exec.Command("psql", url)
	cmd.Stdin = reader

	err = cmd.Run()

	if err != nil {
		log.Panic(err)
	}

}
