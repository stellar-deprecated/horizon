package resource

import (
	"fmt"
	"strings"
	"time"

	"github.com/guregu/null"
	"github.com/stellar/horizon/pkg/db2/history"
	"github.com/stellar/horizon/pkg/httpx"
	"github.com/stellar/horizon/pkg/render/hal"
	"golang.org/x/net/context"
)

// Populate fills out the details
func (res *Transaction) Populate(
	ctx context.Context,
	row history.Transaction,
) (err error) {

	res.ID = row.TransactionHash
	res.PT = row.PagingToken()
	res.Hash = row.TransactionHash
	res.Ledger = row.LedgerSequence
	res.LedgerCloseTime = row.LedgerCloseTime
	res.Account = row.Account
	res.AccountSequence = row.AccountSequence
	res.FeePaid = row.FeePaid
	res.OperationCount = row.OperationCount
	res.EnvelopeXdr = row.TxEnvelope
	res.ResultXdr = row.TxResult
	res.ResultMetaXdr = row.TxMeta
	res.FeeMetaXdr = row.TxFeeMeta
	res.MemoType = row.MemoType
	res.Memo = row.Memo.String
	res.Signatures = strings.Split(row.SignatureString, ",")
	res.ValidBefore = res.timeString(row.ValidBefore)
	res.ValidAfter = res.timeString(row.ValidAfter)

	lb := hal.LinkBuilder{Base: httpx.BaseURL(ctx)}
	res.Links.Account = lb.Link("/accounts", res.Account)
	res.Links.Ledger = lb.Link("/ledgers", fmt.Sprintf("%d", res.Ledger))
	res.Links.Operations = lb.PagedLink("/transactions", res.ID, "operations")
	res.Links.Effects = lb.PagedLink("/transactions", res.ID, "effects")
	res.Links.Self = lb.Link("/transactions", res.ID)
	res.Links.Succeeds = lb.Linkf("/transactions?order=desc&cursor=%s", res.PT)
	res.Links.Precedes = lb.Linkf("/transactions?order=asc&cursor=%s", res.PT)
	return
}

// PagingToken implementation for hal.Pageable
func (res Transaction) PagingToken() string {
	return res.PT
}
func (res *Transaction) timeString(in null.Int) string {
	if !in.Valid {
		return ""
	}

	return time.Unix(in.Int64, 0).UTC().Format(time.RFC3339)
}
