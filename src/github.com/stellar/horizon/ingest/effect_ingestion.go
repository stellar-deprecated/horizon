package ingest

import (
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2/history"
)

func (ei *EffectIngestion) Add(aid xdr.AccountId, typ history.EffectType, details interface{}) error {
	ei.added++

	haid, err := ei.Accounts.Get(aid.Address())
	if err != nil {
		return err
	}

	return ei.Dest.Effect(haid, ei.OperationID, ei.added, typ, details)
}
