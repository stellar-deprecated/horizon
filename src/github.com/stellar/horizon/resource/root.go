package resource

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

// Populate fills in the details
func (res *Root) Populate(ctx context.Context, row db.LedgerState, hVersion string, cVersion string) {
	res.HorizonSequence = row.HorizonSequence
	res.StellarCoreSequence = row.StellarCoreSequence
	res.HorizonVersion = hVersion
	res.StellarCoreVersion = cVersion

	lb := hal.LinkBuilder{httpx.Host(ctx)}
	res.Links.Account = lb.Link("/accounts/{address}")
	res.Links.AccountTransactions = lb.PagedLink("/accounts/{address}/transactions")
	res.Links.Friendbot = lb.Link("/friendbot{?addr}")
	res.Links.Metrics = lb.Link("/metrics")
	res.Links.OrderBook = lb.Link("/order_book{?selling_asset_type,selling_asset_code,selling_issuer,buying_asset_type,buying_asset_code,buying_issuer}")
	res.Links.Self = lb.Link("/")
	res.Links.Transaction = lb.Link("/transactions/{hash}")
	res.Links.Transactions = lb.PagedLink("/transactions")
}
