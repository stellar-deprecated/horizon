package friendbot

import (
	"testing"

	"github.com/stellar/horizon/test"
)

// REGRESSION:  ensure that we can craft a transaction
func TestFriendbot_makeTx(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()

	fb := &Bot{
		Secret:   "SAQWC7EPIYF3XGILYVJM4LVAVSLZKT27CTEI3AFBHU2VRCMQ3P3INPG5",
		Network:  "Test SDF Network ; September 2015",
		sequence: 2,
	}

	_, err := fb.makeTx("GDJIN6W6PLTPKLLM57UW65ZH4BITUXUMYQHIMAZFYXF45PZVAWDBI77Z")

	tt.Require.NoError(err)
}
