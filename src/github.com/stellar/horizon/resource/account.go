package resource

import (
	"fmt"

	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

func (a *Account) Populate(row db.AccountRecord) (err error) {
	a.ID = row.Accountid
	a.PagingToken = row.PagingToken()
	a.Address = row.Accountid
	a.Sequence = row.Seqnum
	a.SubentryCount = row.Numsubentries
	a.InflationDestination = row.Inflationdest.String
	a.HomeDomain = row.HomeDomain.String

	a.Flags.Populate(row)
	a.Thresholds.Populate(row)

	// populate balances
	a.Balances = make([]Balance, len(row.Trustlines)+1)
	for i, tl := range row.Trustlines {
		err = a.Balances[i].Populate(tl)
		if err != nil {
			return
		}
	}

	// add native balance
	err = a.Balances[len(a.Balances)-1].PopulateNative(row.Balance)
	if err != nil {
		return
	}

	// populate signers
	a.Signers = make([]Signer, len(row.Signers)+1)
	for i, s := range row.Signers {
		a.Signers[i].Populate(s)
	}

	a.Signers[len(a.Signers)-1].PopulateMaster(row)

	self := fmt.Sprintf("/accounts/%s", row.Address)
	a.Links = halgo.Links{}.
		Self(self).
		Link("transactions", "%s/transactions%s", self, hal.StandardPagingOptions).
		Link("operations", "%s/operations%s", self, hal.StandardPagingOptions).
		Link("effects", "%s/effects%s", self, hal.StandardPagingOptions).
		Link("offers", "%s/offers%s", self, hal.StandardPagingOptions)

	return
}
