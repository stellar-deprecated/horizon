package core

import (
	"encoding/base64"

	sq "github.com/Masterminds/squirrel"
)

// Raw returns the decoded, raw value of the account data
func (ad AccountData) Raw() ([]byte, error) {
	return base64.StdEncoding.DecodeString(ad.Value)
}

// AccountDataByKey loads a row from `accountdata`, by key
func (q *Q) AccountDataByKey(dest interface{}, addy string, key string) error {
	sql := selectAccountData.Limit(1).
		Where("accountid = ?", addy).
		Where("dataname = ?", key)

	return q.Get(dest, sql)
}

// AllDataByAddress loads all data for `addy`
func (q *Q) AllDataByAddress(dest interface{}, addy string) error {
	sql := selectAccountData.Where("accountid = ?", addy)
	return q.Select(dest, sql)
}

var selectAccountData = sq.Select(
	"ad.accountid",
	"ad.dataname",
	"ad.datavalue",
).From("accountdata ad")
