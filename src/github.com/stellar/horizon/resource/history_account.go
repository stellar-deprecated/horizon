package resource

import (
	"github.com/stellar/horizon/db"
)

func (a *HistoryAccount) Populate(row db.HistoryAccountRecord) {
	a.ID = row.Address
	a.PT = row.PagingToken()
	a.Address = row.Address
}

func (a HistoryAccount) PagingToken() string {
	return a.PT
}
