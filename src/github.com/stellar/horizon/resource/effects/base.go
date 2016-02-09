package effects

import (
	"github.com/stellar/horizon/db/records/history"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

func (this Base) PagingToken() string {
	return this.PT
}

func (this *Base) Populate(ctx context.Context, row history.Effect) {
	this.ID = row.ID()
	this.PT = row.PagingToken()
	this.Account = row.Account
	this.populateType(row)

	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	this.Links.Operation = lb.Linkf("/operations/%d", row.HistoryOperationID)
	this.Links.Succeeds = lb.Linkf("/effects?order=desc&cursor=%s", this.PT)
	this.Links.Precedes = lb.Linkf("/effects?order=asc&cursor=%s", this.PT)
}

func (this *Base) populateType(row history.Effect) {
	var ok bool
	this.TypeI = row.Type
	this.Type, ok = TypeNames[row.Type]

	if !ok {
		this.Type = "unknown"
	}
}
