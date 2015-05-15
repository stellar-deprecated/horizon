package db

import (
	"fmt"
)

type AccountRecord struct {
	HistoryAccountRecord
	CoreAccountRecord
	Trustlines []CoreTrustlineRecord
}

func (r AccountRecord) PagingToken() string {
	return fmt.Sprintf("%d", r.Id)
}
