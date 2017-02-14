package resource

import (
	"encoding/base64"
	"fmt"

	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

// Populate fills out the resource's fields
func (this *Account) Populate(
	ctx context.Context,
	ca core.Account,
	cd []core.AccountData,
	cs []core.Signer,
	ct []core.Trustline,
	ha history.Account,
) (err error) {
	this.ID = ca.Accountid
	this.AccountID = ca.Accountid
	this.Sequence = ca.Seqnum
	this.SubentryCount = ca.Numsubentries
	this.InflationDestination = ca.Inflationdest.String
	this.HomeDomain = ca.HomeDomain.String

	this.Flags.Populate(ca)
	this.Thresholds.Populate(ca)

	// populate balances
	this.Balances = make([]Balance, len(ct)+1)
	for i, tl := range ct {
		err = this.Balances[i].Populate(ctx, tl)
		if err != nil {
			return
		}
	}

	// add native balance
	err = this.Balances[len(this.Balances)-1].PopulateNative(ca.Balance)
	if err != nil {
		return
	}

	// populate data
	this.Data = make(map[string]string)
	for _, d := range cd {
		this.Data[d.Key] = d.Value
	}

	// populate signers
	this.Signers = make([]Signer, len(cs)+1)
	for i, s := range cs {
		this.Signers[i].Populate(ctx, s)
	}

	this.Signers[len(this.Signers)-1].PopulateMaster(ca)

	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	self := fmt.Sprintf("/accounts/%s", ca.Accountid)
	this.Links.Self = lb.Link(self)
	this.Links.Transactions = lb.PagedLink(self, "transactions")
	this.Links.Operations = lb.PagedLink(self, "operations")
	this.Links.Payments = lb.PagedLink(self, "payments")
	this.Links.Effects = lb.PagedLink(self, "effects")
	this.Links.Offers = lb.PagedLink(self, "offers")
	this.Links.Trades = lb.PagedLink(self, "trades")
	this.Links.Data = lb.Link(self, "data/{key}")
	this.Links.Data.PopulateTemplated()
	return
}

// GetData returns decoded value for a given key. If the key does
// not exist, empty slice will be returned.
func (this *Account) GetData(key string) []byte {
	data, exists := this.Data[key]
	if !exists {
		return nil
	}

	// We assume that horizon always returns valid base64 encoded string
	decoded, _ := base64.StdEncoding.DecodeString(data)
	return decoded
}
