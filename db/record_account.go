package db

import (
	"fmt"
)

type AccountRecord struct {
    RecordBase
	HistoryAccountRecord
	CoreAccountRecord
	Trustlines []CoreTrustlineRecord
}

