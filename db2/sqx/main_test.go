package sqx

import (
	"testing"

	sq "github.com/Masterminds/squirrel"
	"github.com/stellar/horizon/test"
)

func TestStringArray(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("base")
	defer tt.Finish()

	expr := StringArray([]string{"1", "2", "3"}).(sq.Sqlizer)
	sql, args, err := expr.ToSql()

	tt.Require.NoError(err)
	tt.Assert.Equal("?::character varying[]", sql)

	tt.Assert.Len(args, 1)
	tt.Assert.Equal(`{"1","2","3"}`, args[0])
}
