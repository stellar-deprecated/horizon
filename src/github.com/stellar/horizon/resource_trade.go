package horizon

import (
	"errors"
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

var (
	ErrInvalidTrade = errors.New("cannot create TradeResource from invalid effect")
)

// EffectResource is the json form of a row from the history_effects
// table.
type TradeResource struct {
	halgo.Links
	ID                string      `json:"id"`
	PagingToken       string      `json:"paging_token"`
	Seller            string      `json:"seller"`
	SoldAssetType     interface{} `json:"sold_asset_type"`
	SoldAssetCode     interface{} `json:"sold_asset_code,omitempty"`
	SoldAssetIssuer   interface{} `json:"sold_asset_issuer,omitempty"`
	Buyer             string      `json:"buyer"`
	BoughtAssetType   interface{} `json:"bought_asset_type"`
	BoughtAssetCode   interface{} `json:"bought_asset_code,omitempty"`
	BoughtAssetIssuer interface{} `json:"bought_asset_issuer,omitempty"`
}

// NewTradeResource initializes a new resource from an EffectRecord
func NewTradeResource(r db.EffectRecord) (result TradeResource, err error) {

	if r.Type != db.EffectTrade {
		err = ErrInvalidTrade
		return
	}

	var details map[string]interface{}
	details, err = r.Details()

	if err != nil {
		return
	}

	seller, ok := details["seller"].(string)
	if !ok {
		err = ErrInvalidTrade
		return
	}

	result = TradeResource{
		Links: halgo.Links{}.
			Link("seller", "/accounts/%s", seller).
			Link("buyer", "/accounts/%s", r.Account).
			Link("order_book", "/order_book?TODO"),
		ID:                r.PagingToken(),
		PagingToken:       r.PagingToken(),
		Seller:            seller,
		SoldAssetType:     details["sold_asset_type"],
		SoldAssetCode:     details["sold_asset_code"],
		SoldAssetIssuer:   details["sold_asset_issuer"],
		Buyer:             r.Account,
		BoughtAssetType:   details["bought_asset_type"],
		BoughtAssetCode:   details["bought_asset_code"],
		BoughtAssetIssuer: details["bought_asset_issuer"],
	}

	return
}

// NewTradeResourcePage initialzed a hal.Page from s a slice of
// EffectRecords
func NewTradeResourcePage(records []db.EffectRecord, query db.PageQuery, path string) (hal.Page, error) {
	fmts := path + "?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		r, err := NewTradeResource(record)
		if err != nil {
			return hal.Page{}, err
		}
		resources[i] = r
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
