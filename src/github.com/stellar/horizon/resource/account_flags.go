package resource

import (
	"github.com/stellar/horizon/db"
	"golang.org/x/net/context"
)

func (this *AccountFlags) Populate(ctx context.Context, row db.AccountRecord) {
	this.AuthRequired = row.IsAuthRequired()
	this.AuthRevocable = row.IsAuthRevocable()
}
