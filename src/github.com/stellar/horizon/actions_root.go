package horizon

import (
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/resource"
)

// RootAction provides a summary of the horizon instance and links to various
// useful endpoints
type RootAction struct {
	Action
}

// JSON renders the json response for RootAction
func (action *RootAction) JSON() {
	action.App.UpdateStellarCoreInfo()

	var res resource.Root
	res.Populate(
		action.Ctx,
		action.App.latestLedgerState,
		action.App.horizonVersion,
		action.App.coreVersion,
	)

	hal.Render(action.W, res)
}
