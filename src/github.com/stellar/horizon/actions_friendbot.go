package horizon

import (
	"net/http"

	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/problem"
	"github.com/zenazn/goji/web"
)

// FriendbotAction causes an account at `Address` to be created.
type FriendbotAction struct {
	TransactionCreateAction
	Address string
}

// JSON is a method for actions.JSON
func (action *FriendbotAction) JSON() {

	action.Do(
		action.checkEnabled,
		action.loadAddress,
		action.loadResult,
		action.loadResource,

		func() {
			hal.Render(action.W, action.Resource)
		})
}

func (action *FriendbotAction) checkEnabled() {
	if action.App.friendbot != nil {
		return
	}

	action.Err = &problem.P{
		Type:   "friendbot_disabled",
		Title:  "Friendbot is disabled",
		Status: http.StatusForbidden,
		Detail: "This horizon server is not configured to provide a friendbot. " +
			"Contact the server administrator if you believe this to be in error.",
	}
}

func (action *FriendbotAction) loadAddress() {
	action.Address = action.GetAddress("addr")
}

func (action *FriendbotAction) loadResult() {
	action.Result = action.App.friendbot.Pay(action.Ctx, action.Address)
}

// ServeHTTPC implements Action for FriendbotAction.  NOTE: We cannot use the
// generated stub because FriendbotAction doesn't directly instantiate the
// template.
func (action FriendbotAction) ServeHTTPC(c web.C, w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(c, w, r)
	ap.Execute(&action)
}
