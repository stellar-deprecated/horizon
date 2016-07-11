package test

import (
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
)

type RequestHelper interface {
	Get(string, ...func(*http.Request)) *httptest.ResponseRecorder
	Post(string, url.Values, ...func(*http.Request)) *httptest.ResponseRecorder
}

type requestHelper struct {
	router *web.Mux
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

func (rh *requestHelper) Get(
	path string,
	mods ...func(*http.Request),
) *httptest.ResponseRecorder {

	req, _ := http.NewRequest("GET", path, nil)
	return rh.Execute(req, mods)
}

func (rh *requestHelper) Post(
	path string,
	form url.Values,
	mods ...func(*http.Request),
) *httptest.ResponseRecorder {

	body := strings.NewReader(form.Encode())
	req, _ := http.NewRequest("POST", path, body)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	return rh.Execute(req, mods)
}

func (rh *requestHelper) Execute(
	req *http.Request,
	requestModFns []func(*http.Request),
) *httptest.ResponseRecorder {

	req.RemoteAddr = "127.0.0.1"
	for _, fn := range requestModFns {
		fn(req)
	}

	w := httptest.NewRecorder()
	c := web.C{
		Env: map[interface{}]interface{}{},
	}

	rh.router.ServeHTTPC(c, w, req)
	return w

}
