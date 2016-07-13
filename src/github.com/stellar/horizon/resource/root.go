package resource

import (
	"github.com/stellar/horizon/httpx"
	"github.com/stellar/horizon/render/hal"
	"golang.org/x/net/context"
)

// Populate fills in the details
func (res *Root) Populate(
	ctx context.Context,
	hLatestSeq, hElderSeq int32,
	cLatestSeq, cElderSeq int32,
	hVersion, cVersion string,
	passphrase string,
) {
	res.HorizonSequence = hLatestSeq
	res.HorizonElderSequence = hElderSeq
	res.CoreSequence = cLatestSeq
	res.CoreElderSequence = cElderSeq
	res.HorizonVersion = hVersion
	res.StellarCoreVersion = cVersion
	res.NetworkPassphrase = passphrase

	lb := hal.LinkBuilder{httpx.BaseURL(ctx)}
	res.Links.Account = lb.Link("/accounts/{account_id}")
	res.Links.AccountTransactions = lb.PagedLink("/accounts/{account_id}/transactions")
	res.Links.Friendbot = lb.Link("/friendbot{?addr}")
	res.Links.Metrics = lb.Link("/metrics")
	res.Links.OrderBook = lb.Link("/order_book{?selling_asset_type,selling_asset_code,selling_issuer,buying_asset_type,buying_asset_code,buying_issuer}")
	res.Links.Self = lb.Link("/")
	res.Links.Transaction = lb.Link("/transactions/{hash}")
	res.Links.Transactions = lb.PagedLink("/transactions")
}
