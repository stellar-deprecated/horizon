package horizon

import (
	"net/http"

	"github.com/stellar/go-horizon/actions"
	"github.com/zenazn/goji/web"
)

type Action struct {
	actions.Base
	App *App
}

func (action *Action) Prepare(c web.C, w http.ResponseWriter, r *http.Request) {
	base := &action.Base
	base.Prepare(c, w, r)
	action.App = action.GojiCtx.Env["app"].(*App)
}
