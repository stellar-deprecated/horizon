package effects

import (
	"github.com/stellar/horizon/db"
)

func (this *AccountCreated) Populate(row db.EffectRecord) error {
	this.Base.Populate(row)
	return row.UnmarshalDetails(this)
}
