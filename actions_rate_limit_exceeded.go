package horizon

import (
	"net/http"

	"github.com/zenazn/goji/web"

	"github.com/stellar/go-horizon/render/problem"
)

// RateLimitExceededAction renders a 429 response
type RateLimitExceededAction struct {
	Action
}

// ServeHTTPC is a method for web.Handler
func (action RateLimitExceededAction) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ap := &action.Action
	ap.Prepare(web.C{}, w, r)
	problem.Render(action.Ctx, action.W, problem.RateLimitExceeded)
}
