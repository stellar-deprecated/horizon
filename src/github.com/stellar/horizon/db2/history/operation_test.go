package history

import (
	"testing"

	"github.com/stellar/horizon/test"
)

func TestOperationQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.HorizonRepo()}

	// Test OperationByID
	var op Operation
	err := q.OperationByID(&op, 8589938689)

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int64(8589938689), op.ID)
	}

}
