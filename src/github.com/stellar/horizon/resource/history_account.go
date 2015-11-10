package resource

import (
	"github.com/stellar/horizon/db"
)

func (a *HistoryAccount) Populate(row db.HistoryAccountRecord) {
	a.ID = row.Address
	a.PagingToken = row.PagingToken()
	a.Address = row.Address
}
