package core

import (
	sq "github.com/lann/squirrel"
)

// SignersByAddress loads all signer rows for `addy`
func (q *Q) SignersByAddress(dest interface{}, addy string) error {
	sql := selectSigner.Where("accountid = ?", addy)
	return q.Select(dest, sql)
}

var selectSigner = sq.Select(
	"si.accountid",
	"si.publickey",
	"si.weight",
).From("signers si")
