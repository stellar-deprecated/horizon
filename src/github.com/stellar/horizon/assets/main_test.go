package assets

import (
	"testing"

	"github.com/stellar/go/xdr"
	"github.com/stretchr/testify/assert"
)

func TestAssets_Parse(t *testing.T) {
	cases := []struct {
		Input       string
		Expected    xdr.AssetType
		ExpectedErr string
	}{
		{"native", xdr.AssetTypeAssetTypeNative, ""},
		{"credit_alphanum4", xdr.AssetTypeAssetTypeCreditAlphanum4, ""},
		{"credit_alphanum12", xdr.AssetTypeAssetTypeCreditAlphanum12, ""},
		{
			"not_real",
			xdr.AssetType(0),
			"invalid asset type: was not one of 'native', 'credit_alphanum4', 'credit_alphanum12'",
		},
		{
			"",
			xdr.AssetType(0),
			"invalid asset type: was not one of 'native', 'credit_alphanum4', 'credit_alphanum12'",
		},
	}

	for _, kase := range cases {
		_ = kase

		actual, err := Parse(kase.Input)

		if kase.ExpectedErr != "" {
			assert.EqualError(t, err, kase.ExpectedErr)
		} else {
			if assert.NoError(t, err) {
				assert.Equal(t, kase.Expected, actual)
			}
		}
	}
}

func TestAssets_String(t *testing.T) {
	cases := []struct {
		Name        string
		Input       xdr.AssetType
		Expected    string
		ExpectedErr string
	}{
		{
			"native",
			xdr.AssetTypeAssetTypeNative,
			"native",
			"",
		},
		{
			"credit_alphanum4",
			xdr.AssetTypeAssetTypeCreditAlphanum4,
			"credit_alphanum4",
			"",
		},
		{
			"credit_alphanum12",
			xdr.AssetTypeAssetTypeCreditAlphanum12,
			"credit_alphanum12",
			"",
		},
		{
			"bad",
			xdr.AssetType(15),
			"",
			"unknown asset type, cannot convert to string",
		},
	}

	for _, kase := range cases {
		_ = kase

		actual, err := String(kase.Input)

		if kase.ExpectedErr != "" {
			assert.EqualError(t, err, kase.ExpectedErr)
		} else {
			if assert.NoError(t, err) {
				assert.Equal(t, kase.Expected, actual)
			}
		}
	}
}
