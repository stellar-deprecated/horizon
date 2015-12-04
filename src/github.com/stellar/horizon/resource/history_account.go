package resource

import (
	"github.com/stellar/horizon/db"
	"golang.org/x/net/context"
)

func (this *HistoryAccount) Populate(ctx context.Context, row db.HistoryAccountRecord) {
	this.ID = row.Address
	this.PT = row.PagingToken()
	this.AccountID = row.Address
}

func (this HistoryAccount) PagingToken() string {
	return this.PT
}
