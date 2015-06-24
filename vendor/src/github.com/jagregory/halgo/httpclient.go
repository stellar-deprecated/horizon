package halgo

import (
	"fmt"
	"net/http"
)

// HttpClient exposes Do from net/http Client.
type HttpClient interface {
	Do(req *http.Request) (*http.Response, error)
}

// LoggingHttpClient is an example HttpClient implementation which wraps
// an existing HttpClient and prints the request URL to STDOUT whenever
// one occurs.
type LoggingHttpClient struct {
	HttpClient
}

func (c LoggingHttpClient) Do(req *http.Request) (*http.Response, error) {
	fmt.Printf("%s %s\n", req.Method, req.URL)
	return c.HttpClient.Do(req)
}
