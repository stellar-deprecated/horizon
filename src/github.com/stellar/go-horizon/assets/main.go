//Package assets is a simple helper package to help convert to/from xdr.AssetType values
package assets

import (
	"errors"
	"github.com/stellar/go-stellar-base/xdr"
)

var ErrInvalidString = errors.New("invalid asset type: was not one of 'native', 'alphanum_4', 'alphanum_12'")
var ErrInvalidValue = errors.New("unknown asset type, cannot convert to string")

var AssetTypeMap = map[string]xdr.AssetType{
	"native":      xdr.AssetTypeAssetTypeNative,
	"alphanum_4":  xdr.AssetTypeAssetTypeCreditAlphanum4,
	"alphanum_12": xdr.AssetTypeAssetTypeCreditAlphanum12,
}

//Parse creates an asset from the provided strings.  See AssetTypeMap for valid strings for aType.
func Parse(aType string) (result xdr.AssetType, err error) {

	result, ok := AssetTypeMap[aType]

	if !ok {
		err = ErrInvalidString
	}

	return
}

//String returns the appropriate string representation of the provided xdr.AssetType.
func String(aType xdr.AssetType) (string, error) {
	for s, v := range AssetTypeMap {
		if v == aType {
			return s, nil
		}
	}

	return "", ErrInvalidValue
}
