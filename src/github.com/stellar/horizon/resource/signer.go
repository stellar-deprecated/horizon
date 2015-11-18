package resource

import (
	"github.com/stellar/horizon/db"
	"golang.org/x/net/context"
)

func (this *Signer) Populate(ctx context.Context, row db.CoreSignerRecord) {
	this.Address = row.Publickey
	this.Weight = row.Weight
}

func (this *Signer) PopulateMaster(row db.AccountRecord) {
	this.Address = row.Accountid
	this.Weight = int32(row.Thresholds[0])
}
