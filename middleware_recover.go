package horizon

import (
	"bytes"
	"fmt"
	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/render/problem"
	"github.com/zenazn/goji/web"
	. "github.com/zenazn/goji/web/middleware"
	"log"
	"net/http"
	"runtime/debug"
)

func RecoverMiddleware(c *web.C, h http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		reqID := GetReqID(*c)

		defer func() {
			if err := recover(); err != nil {
				printPanic(reqID, err)
				debug.PrintStack()
				//TODO: include stack trace if in debug mode
				problem.Render(gctx.FromC(*c), w, problem.ServerError)
			}
		}()

		h.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}

func printPanic(reqID string, err interface{}) {
	var buf bytes.Buffer

	if reqID != "" {
		fmt.Fprintf(&buf, "[%s] ", reqID)
	}
	fmt.Fprintf(&buf, "panic: %+v", err)

	log.Print(buf.String())
}
