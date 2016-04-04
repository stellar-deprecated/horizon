package util

import (
	"database/sql"
	"log"
	// "github.com/stellar/horizon/log"
	"regexp"
	"strings"
)

// SQLBlockComments is a regex that matches against SQL block comments
var SQLBlockComments = regexp.MustCompile(`/\*.*?\*/`)

// SQLLineComments is a regex that matches against SQL line comments
var SQLLineComments = regexp.MustCompile("--.*?\n")

// RunAll runs all sql commands in `script` against `db`
func RunAll(db *sql.DB, script string) error {
	tx, err := db.Begin()
	if err != nil {
		return err
	}

	for _, cmd := range AllStatements(script) {
		log.Println("sql:exec", cmd)

		_, err := tx.Exec(cmd)
		if err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit()
}

// AllStatements takes a sql script, possibly containing comments and multiple
// statements, and returns a slice of strings that correspond to each individual
// SQL statement within the script
func AllStatements(script string) (ret []string) {
	for _, s := range strings.Split(removeComments(script), ";") {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		ret = append(ret, s)
	}
	return
}

func removeComments(script string) string {
	withoutBlocks := SQLBlockComments.ReplaceAllString(script, "")
	return SQLLineComments.ReplaceAllString(withoutBlocks, "")
}
