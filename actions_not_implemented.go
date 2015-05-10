package horizon

import (
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
)

func notImplementedAction(c web.C, w http.ResponseWriter, r *http.Request) {
	problem.Render(context.TODO(), w, problem.NotImplemented)
}
