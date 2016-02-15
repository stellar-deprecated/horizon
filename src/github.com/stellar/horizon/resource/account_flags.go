package resource

import (
	"github.com/stellar/horizon/db/records"
	"golang.org/x/net/context"
)

func (this *AccountFlags) Populate(ctx context.Context, row records.Account) {
	this.AuthRequired = row.IsAuthRequired()
	this.AuthRevocable = row.IsAuthRevocable()
}
