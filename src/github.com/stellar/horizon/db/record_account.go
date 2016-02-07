package db

import (
	"github.com/stellar/horizon/db/records/core"
)

type AccountRecord struct {
	HistoryAccountRecord
	core.Account
	Trustlines []CoreTrustlineRecord
	Signers    []CoreSignerRecord
}
