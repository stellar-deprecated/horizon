package actions

import (
	"fmt"
	"math"
	"net/http"
	"net/url"
	"testing"

	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/render/problem"
	"github.com/stellar/horizon/test"
	"github.com/zenazn/goji/web"
)

func TestGetAccountID(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	aid := action.GetAccountID("4_asset_issuer")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(
		"GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
		aid.Address(),
	)
}

func TestGetAsset(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	ts := action.GetAsset("native_")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeNative, ts.Type)
	}

	ts = action.GetAsset("4_")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeCreditAlphanum4, ts.Type)
	}

	ts = action.GetAsset("12_")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeCreditAlphanum12, ts.Type)
	}

	// bad path
	action.GetAsset("cursor")
	tt.Assert.Error(action.Err)
}

func TestGetAssetType(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	ts := action.GetAssetType("native_asset_type")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeNative, ts)
	}

	ts = action.GetAssetType("4_asset_type")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeCreditAlphanum4, ts)
	}

	ts = action.GetAssetType("12_asset_type")
	if tt.Assert.NoError(action.Err) {
		tt.Assert.Equal(xdr.AssetTypeAssetTypeCreditAlphanum12, ts)
	}
}

func TestGetInt32(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	result := action.GetInt32("blank")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(int32(0), result)

	result = action.GetInt32("zero")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(int32(0), result)

	result = action.GetInt32("two")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(int32(2), result)

	result = action.GetInt32("32max")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int32(math.MaxInt32), result)

	result = action.GetInt32("32min")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int32(math.MinInt32), result)

	result = action.GetInt32("limit")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int32(2), result)

	// overflows
	action.Err = nil
	_ = action.GetInt32("64max")
	if tt.Assert.IsType(&problem.P{}, action.Err) {
		p := action.Err.(*problem.P)
		tt.Assert.Equal("bad_request", p.Type)
		tt.Assert.Equal("64max", p.Extras["invalid_field"])
	}

	action.Err = nil
	_ = action.GetInt32("64min")
	if tt.Assert.IsType(&problem.P{}, action.Err) {
		p := action.Err.(*problem.P)
		tt.Assert.Equal("bad_request", p.Type)
		tt.Assert.Equal("64min", p.Extras["invalid_field"])
	}
}

func TestGetInt64(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	result := action.GetInt64("blank")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int64(0), result)

	result = action.GetInt64("zero")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int64(0), result)

	result = action.GetInt64("two")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(int64(2), result)

	result = action.GetInt64("64max")
	tt.Assert.NoError(action.Err)
	tt.Assert.EqualValues(int64(math.MaxInt64), result)

	result = action.GetInt64("64min")
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal(int64(math.MinInt64), result)
}

func TestGetPagingParams(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	// happy path
	cursor, order, limit := action.GetPagingParams()
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal("hello", cursor)
	tt.Assert.Equal(uint64(2), limit)
	tt.Assert.Equal("", order)

	//Last-Event-ID overrides cursor
	action.R.Header.Set("Last-Event-ID", "from_header")
	cursor, _, _ = action.GetPagingParams()
	tt.Assert.NoError(action.Err)
	tt.Assert.Equal("from_header", cursor)

	// regression: GetPagQuery does not overwrite err
	r, _ := http.NewRequest("GET", "/?limit=foo", nil)
	action.R = r
	_, _, _ = action.GetPagingParams()
	tt.Assert.Error(action.Err)
	_ = action.GetPageQuery()
	tt.Assert.Error(action.Err)
}

func TestGetString(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	tt.Assert.Equal("hello", action.GetString("cursor"))
	action.R.Form = url.Values{
		"cursor": {"goodbye"},
	}
	tt.Assert.Equal("goodbye", action.GetString("cursor"))
}

func TestPath(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()
	action := makeTestAction()

	tt.Assert.Equal("/foo-bar/blah", action.Path())
}

func makeTestAction() *Base {
	r, _ := http.NewRequest("GET", "/foo-bar/blah?limit=2&cursor=hello", nil)
	action := &Base{
		Ctx: test.Context(),
		GojiCtx: web.C{
			URLParams: map[string]string{
				"blank":             "",
				"zero":              "0",
				"two":               "2",
				"32min":             fmt.Sprint(math.MinInt32),
				"32max":             fmt.Sprint(math.MaxInt32),
				"64min":             fmt.Sprint(math.MinInt64),
				"64max":             fmt.Sprint(math.MaxInt64),
				"native_asset_type": "native",
				"4_asset_type":      "credit_alphanum4",
				"4_asset_code":      "USD",
				"4_asset_issuer":    "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
				"12_asset_type":     "credit_alphanum12",
				"12_asset_code":     "USD",
				"12_asset_issuer":   "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H",
			},
			Env: map[interface{}]interface{}{},
		},
		R: r,
	}
	return action
}
