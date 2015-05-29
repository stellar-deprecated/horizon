package problem

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/stellar/go-horizon/context/requestid"
	"github.com/stellar/go-horizon/log"
	"golang.org/x/net/context"
)

// HasProblem types can be transformed into a problem.
// Implement it for custom errors.
type HasProblem interface {
	Problem() P
}

// P is a struct that represents an error response to be rendered to a connected
// client.
type P struct {
	Type     string                 `json:"type"`
	Title    string                 `json:"title"`
	Status   int                    `json:"status"`
	Detail   string                 `json:"detail,omitempty"`
	Instance string                 `json:"instance,omitempty"`
	Extras   map[string]interface{} `json:"extras,omitempty"`
}

// Inflate expands a problem with contextal information.
// At present it adds the request's id as the problem's Instance, if available.
func Inflate(ctx context.Context, p *P) {
	//TODO: inflate type into full url
	//TODO: add requesting url to extra info

	p.Instance = requestid.FromContext(ctx)
}

// Render writes a http response to `w`, compliant with the "Problem
// Details for HTTP APIs" RFC:
//   https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00
//
// `p` is the problem, which may be either a concrete P struct, an implementor
// of the `HasProblem` interface, or an error.  Any other value for `p` will
// panic.
func Render(ctx context.Context, w http.ResponseWriter, p interface{}) {
	switch p := p.(type) {
	case P:
		render(ctx, w, p)
	case HasProblem:
		render(ctx, w, p.Problem())
	case error:
		log.Error(ctx, p)
		render(ctx, w, ServerError)
	default:
		panic(fmt.Sprintf("Invalid problem: %v+", p))
	}
}

func render(ctx context.Context, w http.ResponseWriter, p P) {

	Inflate(ctx, &p)

	w.Header().Set("Content-Type", "application/problem+json")
	js, err := json.MarshalIndent(p, "", "  ")

	if err != nil {
		log.Error(ctx, err)
		http.Error(w, "error rendering problem", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(p.Status)
	w.Write(js)
}

var (
	NotFound          P
	ServerError       P
	RateLimitExceeded P
	NotImplemented    P
)

func init() {
	NotFound = P{
		Type:   "not_found",
		Title:  "Resource Missing",
		Status: http.StatusNotFound,
		Detail: "The resource at the url requested was not found.  This is usually " +
			"occurs for one of two reasons:  The url requested is not valid, or no " +
			"data in our database could be found with the parameters provided.",
	}

	ServerError = P{
		Type:   "server_error",
		Title:  "Internal Server Error",
		Status: http.StatusInternalServerError,
		Detail: "An error occurred while processing this request.  This is usually due " +
			"to a bug within the server software.  Trying this request again may " +
			"succeed if the bug is transient, otherwise please report this issue " +
			"to the issue tracker at: https://github.com/stellar/go-horizon/issues." +
			" Please include this response in your issue.",
	}

	RateLimitExceeded = P{
		Type:   "rate_limit_exceeded",
		Title:  "Rate limit exceeded",
		Status: 429,
		Detail: "The rate limit for the requesting IP address is over its alloted " +
			"limit.  The allowed limit and requests left per time period are " +
			"communicated to clients via the http response headers 'X-RateLimit-*' " +
			"headers.",
	}

	NotImplemented = P{
		Type:   "not_implemented",
		Title:  "Resource Not Yet Implemented",
		Status: http.StatusNotFound,
		Detail: "While the requested URL is expected to eventually point to a " +
			"valid resource, the work to implement the resource has not yet " +
			"been completed.",
	}
}
