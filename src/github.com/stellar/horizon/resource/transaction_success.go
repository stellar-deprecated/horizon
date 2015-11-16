package resource

import (
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/txsub"
)

// Populate fills out the details
func (res *TransactionSuccess) Populate(result txsub.Result) {
	res.Hash = result.Hash
	res.Ledger = result.LedgerSequence
	res.Env = result.EnvelopeXDR
	res.Result = result.ResultXDR
	res.Meta = result.ResultMetaXDR

	lb := hal.LinkBuilder{}
	res.Links.Transaction = lb.Link("/transaction", result.Hash)
	return
}
