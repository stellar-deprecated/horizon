package resource

import (
	"github.com/stellar/horizon/db"
)

func (this *Signer) Populate(row db.CoreSignerRecord) {
	this.Address = row.Publickey
	this.Weight = row.Weight
}

func (this *Signer) PopulateMaster(row db.AccountRecord) {
	this.Address = row.Accountid
	this.Weight = int32(row.Thresholds[0])
}
