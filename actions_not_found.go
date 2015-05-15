package horizon

import (
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"net/http"
)

func notFoundAction(c web.C, w http.ResponseWriter, r *http.Request) {
	ah := &ActionHelper{c: c, r: r}
	problem.Render(ah.Context(), w, problem.NotFound)
}
