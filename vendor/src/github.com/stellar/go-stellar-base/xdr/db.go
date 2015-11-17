package xdr

import (
	"encoding/base64"
	"errors"
	"strings"
)

// This file contains implementations of the sql.Scanner interface for stellar xdr types

func (this *AccountFlags) Scan(src interface{}) error {
	val, ok := src.(int64)
	if !ok {
		return errors.New("Invalid value for xdr.AccountFlags")
	}

	*this = AccountFlags(val)
	return nil
}

func (this *AssetType) Scan(src interface{}) error {
	val, ok := src.(int64)
	if !ok {
		return errors.New("Invalid value for xdr.AssetType")
	}

	*this = AssetType(val)
	return nil
}

func (this *Int64) Scan(src interface{}) error {
	val, ok := src.(int64)
	if !ok {
		return errors.New("Invalid value for xdr.Int64")
	}

	*this = Int64(val)
	return nil
}

func (this *Thresholds) Scan(src interface{}) error {
	var val string

	switch src := src.(type) {
	case []byte:
		val = string(src)
	case string:
		val = src
	default:
		return errors.New("Invalid value for xdr.Thresholds")
	}

	reader := strings.NewReader(val)
	b64r := base64.NewDecoder(base64.StdEncoding, reader)

	_, err := Unmarshal(b64r, this)
	return err

}
