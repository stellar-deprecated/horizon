package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
)

// NotFoundAction renders a 404 response
type NotFoundAction struct {
	Action
}

// ServeHTTPC is a method for web.Handler
func (action NotFoundAction) ServeHTTPC(c web.C, w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(c, w, r)
	ap.Execute(&action)
}

// JSON is a method for actions.JSON
func (action *NotFoundAction) JSON() {
	problem.Render(action.Ctx, action.W, problem.NotFound)
}
