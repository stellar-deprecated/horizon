package resource

import (
	"fmt"

	"github.com/stellar/horizon/db/records"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

// Populate fills out the resource's fields
func (this *Account) Populate(ctx context.Context, row records.Account) (err error) {
	this.ID = row.Accountid
	this.PT = row.History.PagingToken()
	this.AccountID = row.Accountid
	this.Sequence = row.Seqnum
	this.SubentryCount = row.Numsubentries
	this.InflationDestination = row.Inflationdest.String
	this.HomeDomain = row.HomeDomain.String

	this.Flags.Populate(ctx, row)
	this.Thresholds.Populate(ctx, row)

	// populate balances
	this.Balances = make([]Balance, len(row.Trustlines)+1)
	for i, tl := range row.Trustlines {
		err = this.Balances[i].Populate(ctx, tl)
		if err != nil {
			return
		}
	}

	// add native balance
	err = this.Balances[len(this.Balances)-1].PopulateNative(row.Balance)
	if err != nil {
		return
	}

	// populate signers
	this.Signers = make([]Signer, len(row.Signers)+1)
	for i, s := range row.Signers {
		this.Signers[i].Populate(ctx, s)
	}

	this.Signers[len(this.Signers)-1].PopulateMaster(row)

	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	self := fmt.Sprintf("/accounts/%s", row.History.Address)
	this.Links.Self = lb.Link(self)
	this.Links.Transactions = lb.PagedLink(self, "transactions")
	this.Links.Operations = lb.PagedLink(self, "operations")
	this.Links.Payments = lb.PagedLink(self, "payments")
	this.Links.Effects = lb.PagedLink(self, "effects")
	this.Links.Offers = lb.PagedLink(self, "offers")

	return
}
