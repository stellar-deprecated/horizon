package history

import (
	"testing"

	"github.com/stellar/horizon/pkg/test"
)

func TestLedgerCache(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.HorizonSession()}

	t.Run("queue and load", func(t *testing.T) {
		var lc LedgerCache

		lc.Queue(2)
		lc.Queue(3)

		err := lc.Load(q)

		if tt.Assert.NoError(err) {
			tt.Assert.Contains(lc.Records, int32(2))
			tt.Assert.Contains(lc.Records, int32(3))
			tt.Assert.NotContains(lc.Records, int32(1))
		}
	})
}
