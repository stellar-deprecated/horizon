package resource

import (
	"github.com/stellar/horizon/db"
)

func (at *AccountThresholds) Populate(row db.AccountRecord) {
	at.LowThreshold = row.Thresholds[1]
	at.MedThreshold = row.Thresholds[2]
	at.HighThreshold = row.Thresholds[3]
}
