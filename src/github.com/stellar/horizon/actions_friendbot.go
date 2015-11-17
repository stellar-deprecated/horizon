package horizon

import (
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/problem"
	"net/http"
)

type FriendbotAction struct {
	TransactionCreateAction
	Address string
}

// JSON is a method for actions.JSON
func (action *FriendbotAction) JSON() {

	action.Do(
		action.CheckEnabled,
		action.LoadAddress,
		action.LoadResult,
		action.LoadResource,

		func() {
			hal.Render(action.W, action.Resource)
		})
}

func (action *FriendbotAction) CheckEnabled() {
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

func (action *FriendbotAction) LoadAddress() {
	action.Address = action.GetAddress("addr")
}

func (action *FriendbotAction) LoadResult() {
	action.Result = action.App.friendbot.Pay(action.Ctx, action.Address)
}
