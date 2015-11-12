package resource

import (
	"github.com/stellar/horizon/db"
)

func (this *AccountThresholds) Populate(row db.AccountRecord) {
	this.LowThreshold = row.Thresholds[1]
	this.MedThreshold = row.Thresholds[2]
	this.HighThreshold = row.Thresholds[3]
}
