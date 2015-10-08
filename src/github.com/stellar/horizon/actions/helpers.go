package actions

import (
	"net/http"
	"strconv"

	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/problem"
)

const (
	// ParamCursor is a query string param name
	ParamCursor = "cursor"
	// ParamOrder is a query string param name
	ParamOrder = "order"
	// ParamLimit is a query string param name
	ParamLimit = "limit"
)

// OrderBookParams is a helper struct that encapsulates the specification for
// an order book
type OrderBookParams struct {
	SellingType   xdr.AssetType
	SellingIssuer string
	SellingCode   string
	BuyingType    xdr.AssetType
	BuyingIssuer  string
	BuyingCode    string
}

// GetString retrieves a string from either the URLParams, form or query string.
// This method uses the priority (URLParams, Form, Query).
func (base *Base) GetString(name string) string {
	if base.Err != nil {
		return ""
	}

	fromURL, ok := base.GojiCtx.URLParams[name]

	if ok {
		return fromURL
	}

	fromForm := base.R.FormValue(name)

	if fromForm != "" {
		return fromForm
	}

	return base.R.URL.Query().Get(name)
}

// GetInt64 retrieves an int64 from the action parameter of the given name.
// Populates err if the value is not a valid int64
func (base *Base) GetInt64(name string) int64 {
	if base.Err != nil {
		return 0
	}

	asStr := base.GetString(name)

	if asStr == "" {
		return 0
	}

	asI64, err := strconv.ParseInt(asStr, 10, 64)

	if err != nil {
		base.SetInvalidField(name, err)
		return 0
	}

	return asI64
}

// ValidateInt64 populates err if the value is not a valid int64
func (base *Base) ValidateInt64(name string) {
	_ = base.GetInt64(name)
}

// GetInt32 retrieves an int32 from the action parameter of the given name.
// Populates err if the value is not a valid int32
func (base *Base) GetInt32(name string) int32 {
	if base.Err != nil {
		return 0
	}

	asStr := base.GetString(name)

	if asStr == "" {
		return 0
	}

	asI64, err := strconv.ParseInt(asStr, 10, 32)

	if err != nil {
		base.SetInvalidField(name, err)
		return 0
	}

	return int32(asI64)
}

// GetPagingParams returns the cursor/order/limit triplet that is the
// standard way of communicating paging data to a horizon endpoint.
func (base *Base) GetPagingParams() (cursor string, order string, limit int32) {
	if base.Err != nil {
		return
	}

	cursor = base.GetString(ParamCursor)
	order = base.GetString(ParamOrder)
	limit = base.GetInt32(ParamLimit)

	if lei := base.R.Header.Get("Last-Event-ID"); lei != "" {
		cursor = lei
	}

	return
}

// GetPageQuery is a helper that returns a new db.PageQuery struct initialized
// using the results from a call to GetPagingParams()
func (base *Base) GetPageQuery() db.PageQuery {
	if base.Err != nil {
		return db.PageQuery{}
	}

	r, err := db.NewPageQuery(base.GetPagingParams())

	if err != nil {
		base.Err = err
	}

	return r
}

// GetAssetType is a helper that returns a xdr.AssetType by reading a string
func (base *Base) GetAssetType(name string) xdr.AssetType {
	if base.Err != nil {
		return xdr.AssetTypeAssetTypeNative
	}

	r, err := assets.Parse(base.GetString(name))

	if base.Err != nil {
		return xdr.AssetTypeAssetTypeNative
	}

	if err != nil {
		base.SetInvalidField(name, err)
	}

	return r
}

// GetOrderBook returns an OrderBookParams from the url params
func (base *Base) GetOrderBook() (result OrderBookParams) {
	if base.Err != nil {
		return
	}

	result = OrderBookParams{
		SellingType:   base.GetAssetType("selling_asset_type"),
		SellingIssuer: base.GetString("selling_asset_issuer"),
		SellingCode:   base.GetString("selling_asset_code"),
		BuyingType:    base.GetAssetType("buying_asset_type"),
		BuyingIssuer:  base.GetString("buying_asset_issuer"),
		BuyingCode:    base.GetString("buying_asset_code"),
	}

	if base.Err != nil {
		goto InvalidOrderBook
	}

	if result.SellingType != xdr.AssetTypeAssetTypeNative {
		if result.SellingCode == "" {
			goto InvalidOrderBook
		}

		if result.SellingIssuer == "" {
			goto InvalidOrderBook
		}
	}

	if result.BuyingType != xdr.AssetTypeAssetTypeNative {
		if result.BuyingCode == "" {
			goto InvalidOrderBook
		}

		if result.BuyingIssuer == "" {
			goto InvalidOrderBook
		}
	}

	return

InvalidOrderBook:
	base.Err = &problem.P{
		Type:   "invalid_order_book",
		Title:  "Invalid Order Book Parameters",
		Status: http.StatusBadRequest,
		Detail: "The parameters that specify what order book to view are invalid in some way. " +
			"Please ensure that your type parameters (selling_asset_type and buying_asset_type) are one the " +
			"following valid values: native, credit_alphanum4, credit_alphanum12.  Also ensure that you " +
			"have specified selling_asset_code and selling_issuer if selling_asset_type is not 'native', as well " +
			"as buying_asset_code and buying_issuer if buying_asset_type is not 'native'",
	}

	return
}


func (base *Base) SetInvalidField(name string, reason error) {
	br := problem.BadRequest

	br.Extras = map[string]interface{}{}
	br.Extras["invalid_field"] = name
	br.Extras["reason"] = reason.Error()

	base.Err = &br
}

// Path returns the current action's path, as determined by the http.Request of
// this action
func (base *Base) Path() string {
	return base.R.URL.Path
}
