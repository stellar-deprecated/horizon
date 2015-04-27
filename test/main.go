// This package contains simple test helpers that should not
// have any dependencies on horizon's packages.  think constants,
// custom matchers, generic helpers etc.
package test

import (
	"bytes"
	"database/sql"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
)

const (
	DefaultTestDatabaseUrl = "postgres://localhost:5432/horizon_test?sslmode=disable"
)

func DatabaseUrl() string {
	databaseUrl := os.Getenv("DATABASE_URL")

	if databaseUrl == "" {
		databaseUrl = DefaultTestDatabaseUrl
	}

	return databaseUrl
}

func OpenDatabase(dsn string) *sql.DB {
	db, err := sql.Open("postgres", dsn)

	if err != nil {
		log.Panic(err)
	}

	return db
}

func LoadScenario(scenarioName string) {
	scenarioBasePath := "./test/scenarios/" + scenarioName
	horizonPath := scenarioBasePath + "-horizon.sql"

	loadSqlFile(DatabaseUrl(), horizonPath)
}

func loadSqlFile(url string, path string) {
	sql, err := ioutil.ReadFile(path)

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

	_ = cmd.Wait()
}
