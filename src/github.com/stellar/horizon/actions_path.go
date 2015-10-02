package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/render/hal"
)

type PathIndexAction struct {
	Action
}

func (action *PathIndexAction) JSON() {
	result := hal.Page{
		Links: halgo.Links{}.Self(action.R.URL.Path),
		Records: []interface{}{
			PathResource{
				SourceAssetType: "native",
				SourceAmount:    "122345.00000",
				Path: []PathAssetResource{
					{"credit_alphanum4", "USD", "12345"},
					{"credit_alphanum4", "EUR", "12345"},
				},
			},
		},
	}
	hal.Render(action.W, result)
}

type PathResource struct {
	SourceAssetType   string              `json:"source_asset_type"`
	SourceAssetCode   string              `json:"source_asset_code,omitempty"`
	SourceAssetIssuer string              `json:"source_asset_issuer,omitempty"`
	SourceAmount      string              `json:"source_amount"`
	Path              []PathAssetResource `json:"path"`
}

type PathAssetResource struct {
	Type   string `json:"asset_type"`
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"asset_issuer,omitempty"`
}
