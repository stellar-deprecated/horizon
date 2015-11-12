package resource

import (
	"github.com/stellar/horizon/db"
)

func (this *AccountFlags) Populate(row db.AccountRecord) {
	this.AuthRequired = row.IsAuthRequired()
	this.AuthRevocable = row.IsAuthRevocable()
}
