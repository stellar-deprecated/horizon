package horizon

import (
	"net/http"
	"strconv"

	gctx "github.com/goji/context"
	"github.com/stellar/go-horizon/db"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
)

// ActionHelper wraps the goji context and provides helper functions
// to make defining actions easier.
//
// Notably, this object provides a means of more simply extracting information
// from the Query, Form and URLParams.  Any call to the Get* methods (GetInt,
// GetString, etc.) that fails will populate the Err field and subsequent calls
// to Get* will be no ops.  This allows the simpler pattern:
//
//	ah = &ActionHelper{C:c}
//	id := ah.GetInt("id")
//	order := ah.GetString("order")
//
//	if ah.Err() != nil {
//	  // write an error response here
//	  return
//	}
//
type ActionHelper struct {
	c   web.C
	r   *http.Request
	err error
}

// Err returns the first error that was encountered while extracting paramters
// from the action.
func (a *ActionHelper) Err() error {
	return a.err
}

// App retrieves the instance of App that this request is bound to
func (a *ActionHelper) App() *App {
	return a.c.Env["app"].(*App)
}

// Context returns the context for the request
func (a *ActionHelper) Context() context.Context {
	return gctx.FromC(a.c)
}

// GetString retrieves a string from either the URLParams, form or query string.
// This method uses the priority (URLParams, Form, Query).
func (a *ActionHelper) GetString(name string) string {
	if a.err != nil {
		return ""
	}

	fromURL, ok := a.c.URLParams[name]

	if ok {
		return fromURL
	}

	fromForm := a.r.FormValue(name)

	if fromForm != "" {
		return fromForm
	}

	return a.r.URL.Query().Get(name)
}

// GetInt64 retrieves an int64 from the action parameter of the given name.
// Populates err if the value is not a valid int64
func (a *ActionHelper) GetInt64(name string) int64 {
	if a.err != nil {
		return 0
	}

	asStr := a.GetString(name)

	if asStr == "" {
		return 0
	}

	asI64, err := strconv.ParseInt(asStr, 10, 64)

	if err != nil {
		a.err = err
		return 0
	}

	return asI64
}

// GetInt32 retrieves an int32 from the action parameter of the given name.
// Populates err if the value is not a valid int32
func (a *ActionHelper) GetInt32(name string) int32 {
	if a.err != nil {
		return 0
	}

	asStr := a.GetString(name)

	if asStr == "" {
		return 0
	}

	asI64, err := strconv.ParseInt(asStr, 10, 32)

	if err != nil {
		a.err = err
		return 0
	}

	return int32(asI64)
}

// GetPagingParams returns the cursor/order/limit triplet that is the
// standard way of communicating paging data to a horizon endpoint.
func (a *ActionHelper) GetPagingParams() (cursor string, order string, limit int32) {
	if a.err != nil {
		return
	}

	cursor = a.GetString("cursor")
	order = a.GetString("order")
	limit = a.GetInt32("limit")

	if lei := a.r.Header.Get("Last-Event-ID"); lei != "" {
		cursor = lei
	}

	return
}

// GetPageQuery is a helper that returns a new db.PageQuery struct initialized
// using the results from a call to GetPagingParams()
func (a *ActionHelper) GetPageQuery() db.PageQuery {
	r, err := db.NewPageQuery(a.GetPagingParams())
	a.err = err
	return r
}
