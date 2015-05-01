package problem

import (
	"encoding/json"
	"golang.org/x/net/context"
	"net/http"
)

type HasProblem interface {
	Problem() P
}

type P struct {
	Type     string `json:"type"`
	Title    string `json:"title"`
	Status   int    `json:"status"`
	Detail   string `json:"detail,omitempty"`
	Instance string `json:"instance,omitempty"`
}

func FromError(ctx context.Context, err error) P {
	if err, ok := err.(HasProblem); ok {
		return err.Problem()
	}

	result := ServerError
	result.Detail += "\n\nActual Error:" + err.Error()

	return result
}

func Render(ctx context.Context, w http.ResponseWriter, p P) {

	//TODO: inflate type into full url
	//TODO: add requesting url to extra info

	w.Header().Set("Content-Type", "application/problem+json")
	js, err := json.MarshalIndent(p, "", "  ")

	if err != nil {
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
		Status: http.StatusForbidden,
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
