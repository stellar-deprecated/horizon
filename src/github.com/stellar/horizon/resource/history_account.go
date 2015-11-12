package resource

import (
	"github.com/stellar/horizon/db"
)

func (this *HistoryAccount) Populate(row db.HistoryAccountRecord) {
	this.ID = row.Address
	this.PT = row.PagingToken()
	this.Address = row.Address
}

func (this HistoryAccount) PagingToken() string {
	return this.PT
}
