package operations

import (
	"fmt"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

func (this Base) PagingToken() string {
	return this.PT
}

func (this *Base) Populate(ctx context.Context, row db.OperationRecord) {
	this.ID = fmt.Sprintf("%d", row.Id)
	this.PT = row.PagingToken()
	this.SourceAccount = row.SourceAccount
	this.populateType(row)

	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	self := fmt.Sprintf("/operations/%d", row.Id)
	this.Links.Self = lb.Link(self)
	this.Links.Succeeds = lb.Linkf("/effects?order=desc&cursor=%s", this.PT)
	this.Links.Precedes = lb.Linkf("/effects?order=asc&cursor=%s", this.PT)
	this.Links.Transaction = lb.Linkf("/transactions/%s", row.TransactionHash)
	this.Links.Effects = lb.Link(self, "effects")
}

func (this *Base) populateType(row db.OperationRecord) {
	var ok bool
	this.TypeI = int32(row.Type)
	this.Type, ok = TypeNames[row.Type]

	if !ok {
		this.Type = "unknown"
	}
}
