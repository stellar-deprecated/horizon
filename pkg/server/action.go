package server

import (
	"net/http"
	"net/url"
	"strings"

	"github.com/stellar/horizon/pkg/actions"
	"github.com/stellar/horizon/pkg/db2/core"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/httpx"
	"github.com/stellar/horizon/pkg/ledger"
	"github.com/stellar/horizon/pkg/log"
	"github.com/stellar/horizon/pkg/render/problem"
	"github.com/stellar/horizon/pkg/toid"
	"github.com/zenazn/goji/web"
)

// Action is the "base type" for all actions in horizon.  It provides
// structs that embed it with access to the App struct.
//
// Additionally, this type is a trigger for go-codegen and causes
// the file at Action.tmpl to be instantiated for each struct that
// embeds Action.
type Action struct {
	actions.Base
	App *App
	Log *log.Entry

	hq *history.Q
	cq *core.Q
}

// CoreQ provides access to queries that access the stellar core database.
func (action *Action) CoreQ() *core.Q {
	if action.cq == nil {
		action.cq = &core.Q{Session: action.App.CoreSession(action.Ctx)}
	}

	return action.cq
}

// HistoryQ provides access to queries that access the history portion of
// horizon's database.
func (action *Action) HistoryQ() *history.Q {
	if action.hq == nil {
		action.hq = &history.Q{Session: action.App.HorizonSession(action.Ctx)}
	}

	return action.hq
}

// Prepare sets the action's App field based upon the goji context
func (action *Action) Prepare(c web.C, w http.ResponseWriter, r *http.Request) {
	base := &action.Base
	base.Prepare(c, w, r)
	action.App = action.GojiCtx.Env["app"].(*App)

	if action.Ctx != nil {
		action.Log = log.Ctx(action.Ctx)
	} else {
		action.Log = log.DefaultLogger
	}
}

// ValidateCursorAsDefault ensures that the cursor parameter is valid in the way
// it is normally used, i.e. it is either the string "now" or a string of
// numerals that can be parsed as an int64.
func (action *Action) ValidateCursorAsDefault() {
	if action.Err != nil {
		return
	}

	if action.GetString(actions.ParamCursor) == "now" {
		return
	}

	action.GetInt64(actions.ParamCursor)
}

// ValidateCursorWithinHistory compares the requested page of data against the
// ledger state of the history database.  In the event that the cursor is
// guaranteed to return no results, we return a 410 GONE http response.
func (action *Action) ValidateCursorWithinHistory() {
	if action.Err != nil {
		return
	}

	pq := action.GetPageQuery()
	if action.Err != nil {
		return
	}

	// an ascending query should never return a gone response:  An ascending query
	// prior to known history should return results at the beginning of history,
	// and an ascending query beyond the end of history should not error out but
	// rather return an empty page (allowing code that tracks the procession of
	// some resource more easily).
	if pq.Order != "desc" {
		return
	}

	var cursor int64
	var err error

	// HACK: checking for the presence of "-" to see whether we should use
	// CursorInt64 or CursorInt64Pair is gross.
	if strings.Contains(pq.Cursor, "-") {
		cursor, _, err = pq.CursorInt64Pair("-")
	} else {
		cursor, err = pq.CursorInt64()
	}

	if err != nil {
		action.Err = err
		return
	}

	elder := toid.New(ledger.CurrentState().HistoryElder, 0, 0)

	if cursor <= elder.ToInt64() {
		action.Err = &problem.BeforeHistory
	}
}

// EnsureHistoryFreshness halts processing and raises
func (action *Action) EnsureHistoryFreshness() {
	if action.Err != nil {
		return
	}

	if action.App.IsHistoryStale() {
		ls := ledger.CurrentState()
		err := problem.StaleHistory
		err.Extras = map[string]interface{}{
			"history_latest_ledger": ls.HistoryLatest,
			"core_latest_ledger":    ls.CoreLatest,
		}
		action.Err = &err
	}
}

// BaseURL returns the base url for this requestion, defined as a url containing
// the Host and Scheme portions of the request uri.
func (action *Action) BaseURL() *url.URL {
	return httpx.BaseURL(action.Ctx)
}
