package resource

import (
	"fmt"
	_ "golang.org/x/net/context"

	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

func (a *Account) Populate(row db.AccountRecord) (err error) {
	a.ID = row.Accountid
	a.PT = row.PagingToken()
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

	lb := hal.LinkBuilder{}
	self := fmt.Sprintf("/accounts/%s", row.Address)
	a.Links.Self = lb.Link(self)
	a.Links.Transactions = lb.PagedLink(self, "transactions")
	a.Links.Operations = lb.PagedLink(self, "operations")
	a.Links.Payments = lb.PagedLink(self, "payments")
	a.Links.Effects = lb.PagedLink(self, "effects")
	a.Links.Offers = lb.PagedLink(self, "Offers")

	return
}
