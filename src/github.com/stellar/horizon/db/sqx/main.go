// Package sqx contains utilities and extensions for the squirrel package which
// is used by horizon to generate sql statements.
package sqx

import (
	"fmt"
	"strings"

	sq "github.com/lann/squirrel"
)

// StringArray returns a sq.Expr suitable for inclusion in an insert that represents
// the Postgres-compatible array insert.
func StringArray(str []string) interface{} {
	return sq.Expr(
		"?::character varying[]",
		fmt.Sprintf("{%s}", strings.Join(str, ",")),
	)
}
