package resource

import (
	"github.com/stellar/horizon/db"
)

func (s *Signer) Populate(row db.CoreSignerRecord) {
	s.Address = row.Publickey
	s.Weight = row.Weight
}

func (s *Signer) PopulateMaster(row db.AccountRecord) {
	s.Address = row.Accountid
	s.Weight = int32(row.Thresholds[0])
}
