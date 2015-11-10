package resource

import (
	"github.com/stellar/horizon/db"
)

func (af *AccountFlags) Populate(row db.AccountRecord) {
	af.AuthRequired = row.IsAuthRequired()
	af.AuthRevocable = row.IsAuthRevocable()
}
