package base

type Price struct {
	N int32 `json:"n"`
	D int32 `json:"d"`
}

type Asset struct {
	Type   string `json:"asset_type"`
	Code   string `json:"asset_code,omitempty"`
	Issuer string `json:"asset_issuer,omitempty"`
}
