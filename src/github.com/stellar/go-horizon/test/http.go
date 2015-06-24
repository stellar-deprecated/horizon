package test

import (
	"github.com/zenazn/goji/web"
	"net/http"
	"net/http/httptest"
)

type RequestHelper interface {
	Get(string, func(*http.Request)) *httptest.ResponseRecorder
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

func NewRequestHelper(router *web.Mux) RequestHelper {
	return &requestHelper{router}
}

func (r *requestHelper) Get(
	path string,
	requestModFn func(*http.Request),
) *httptest.ResponseRecorder {

	req, _ := http.NewRequest("GET", path, nil)
	req.RemoteAddr = "127.0.0.1"
	requestModFn(req)

	w := httptest.NewRecorder()
	c := web.C{
		Env: map[interface{}]interface{}{},
	}

	r.router.ServeHTTPC(c, w, req)
	return w
}
