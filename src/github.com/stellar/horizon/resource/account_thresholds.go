package resource

import (
	"github.com/stellar/horizon/db"
	"golang.org/x/net/context"
)

func (this *AccountThresholds) Populate(ctx context.Context, row db.AccountRecord) {
	this.LowThreshold = row.Thresholds[1]
	this.MedThreshold = row.Thresholds[2]
	this.HighThreshold = row.Thresholds[3]
}
