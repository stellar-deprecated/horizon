package horizon

import (
	"github.com/stellar/go-horizon/render/problem"
	"golang.org/x/net/context"
	"net/http"
)

func rateLimitExceededAction(w http.ResponseWriter, r *http.Request) {
	problem.Render(context.TODO(), w, problem.RateLimitExceeded)
}
