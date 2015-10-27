package horizon

import (
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/txsub"
	"net/http"
)

type FriendbotAction struct {
	Action
	Address string
	Result  txsub.Result
}

// JSON is a method for actions.JSON
func (action *FriendbotAction) JSON() {
	action.Do(
		action.CheckEnabled,
		action.LoadAddress,
		action.LoadResult,
		func() {
			resource := &ResultResource{action.Result}

			if resource.IsSuccess() {
				hal.Render(action.W, resource.Success())
			} else {
				problem.Render(action.Ctx, action.W, resource.Error())
			}
		},
	)
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
