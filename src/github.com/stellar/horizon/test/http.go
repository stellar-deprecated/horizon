package test

import (
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
)

type RequestHelper interface {
	Get(string, func(*http.Request)) *httptest.ResponseRecorder
	Post(string, url.Values, func(*http.Request)) *httptest.ResponseRecorder
}

type requestHelper struct {
	router *web.Mux
}

func RequestHelperNoop(r *http.Request) {

}

func RequestHelperRemoteAddr(ip string) func(r *http.Request) {
	return func(r *http.Request) {
		r.RemoteAddr = ip
	}
}

func RequestHelperXFF(xff string) func(r *http.Request) {
	return func(r *http.Request) {
		r.Header.Set("X-Forwarded-For", xff)
	}
}

func RequestHelperStreaming(r *http.Request) {
	r.Header.Set("Accept", "text/event-stream")
}

func NewRequestHelper(router *web.Mux) RequestHelper {
	return &requestHelper{router}
}

func (r *requestHelper) Get(
	path string,
	requestModFn func(*http.Request),
) *httptest.ResponseRecorder {

	req, _ := http.NewRequest("GET", path, nil)
	return r.Execute(req, requestModFn)
}

func (r *requestHelper) Post(
	path string,
	form url.Values,
	requestModFn func(*http.Request),
) *httptest.ResponseRecorder {

	body := strings.NewReader(form.Encode())
	req, _ := http.NewRequest("POST", path, body)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	return r.Execute(req, requestModFn)
}

func (r *requestHelper) Execute(
	req *http.Request,
	requestModFn func(*http.Request),
) *httptest.ResponseRecorder {

	req.RemoteAddr = "127.0.0.1"
	requestModFn(req)

	w := httptest.NewRecorder()
	c := web.C{
		Env: map[interface{}]interface{}{},
	}

	r.router.ServeHTTPC(c, w, req)
	return w

}
