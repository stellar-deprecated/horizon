package ingest

import (
	"encoding/base64"
	"fmt"

	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/toid"
)

// InLedger returns true if the cursor is on a ledger.
func (c *Cursor) InLedger() bool {
	return c.lg != 0
}

// InOperation returns true if the cursor is on a operation. Will return false
// after advancing to a new transaction but before advancing on to the
// transaciton's first operation.
func (c *Cursor) InOperation() bool {
	return c.InLedger() && c.op != -1
}

// InTransaction returns true if the cursor is pointing to a transaction.  This
// will return false after advancing to a new ledger but prior to advancing into
// the ledger's first transaction.
func (c *Cursor) InTransaction() bool {
	return c.InLedger() && c.tx != -1
}

// Ledger returns the current ledger
func (c *Cursor) Ledger() *core.LedgerHeader {
	return &c.data.Header
}

// LedgerID returns the current ledger's id, as used by the history system.
func (c *Cursor) LedgerID() int64 {
	return toid.New(c.lg, 0, 0).ToInt64()
}

// LedgerOperationCount returns the count of operations in the current ledger
func (c *Cursor) LedgerOperationCount() (ret int) {
	for i := range c.data.Transactions {
		ret += len(c.data.Transactions[i].Envelope.Tx.Operations)
	}
	return
}

// LedgerRange returns the beginning and end of id values that map to the
// current ledger.  Useful for clearing a ledgers worth of data.
func (c *Cursor) LedgerRange() (start int64, end int64) {
	if c.lg == 1 {
		start = 0
	} else {
		start = toid.New(c.lg, 0, 0).ToInt64()
	}

	return start, toid.New(c.lg+1, 0, 0).ToInt64()
}

// LedgerSequence returns the current ledger's sequence
func (c *Cursor) LedgerSequence() int32 {
	return c.data.Sequence
}

// NextLedger advances `c` to the next ledger in the iteration, loading a new
// LedgerBundle from the core database. Returns false if an error occurs or
// the iteration is complete.
func (c *Cursor) NextLedger() bool {
	if c.Err != nil {
		return false
	}

	if c.lg == 0 {
		c.lg = c.FirstLedger
	} else {
		c.lg++
	}

	if c.lg > c.LastLedger {
		c.data = nil
		c.lg = 0
		return false
	}

	c.data = &LedgerBundle{Sequence: c.lg}
	c.Err = c.data.Load(c.DB)
	if c.Err != nil {
		return false
	}

	c.tx = -1
	c.op = -1

	return true
}

// NextOp advances `c` to the next operation in the current transaction.  Returns
// false if the current transaction has nothing left to visit.
func (c *Cursor) NextOp() bool {
	if c.Err != nil {
		return false
	}
	c.op++
	return c.op < len(c.Operations())
}

// NextTx advances `c` to the next transaction in the current ledger.  Returns
// false if the current ledger has no transactions left to visit.
func (c *Cursor) NextTx() bool {
	if c.Err != nil {
		return false
	}
	c.tx++
	c.op = -1
	return c.tx < len(c.data.Transactions)
}

// Operation returns the current operation
func (c *Cursor) Operation() *xdr.Operation {
	return &c.data.Transactions[c.tx].Envelope.Tx.Operations[c.op]
}

// OperationCount returns the count of operations in the current transaction
func (c *Cursor) OperationCount() int {
	return len(c.data.Transactions[c.tx].Envelope.Tx.Operations)
}

// OperationDetails returns the details regarding the current operation, suitable
// for ingestion into a history_operation row
func (c *Cursor) OperationDetails() map[string]interface{} {
	details := map[string]interface{}{}
	source := c.OperationSourceAccount()

	switch c.OperationType() {
	case xdr.OperationTypeCreateAccount:
		op := c.Operation().Body.MustCreateAccountOp()
		details["funder"] = source.Address()
		details["account"] = op.Destination.Address()
		details["starting_balance"] = amount.String(op.StartingBalance)
	case xdr.OperationTypePayment:
		op := c.Operation().Body.MustPaymentOp()
		details["from"] = source.Address()
		details["to"] = op.Destination.Address()
		details["amount"] = amount.String(op.Amount)
		c.assetDetails(details, op.Asset, "")
	case xdr.OperationTypePathPayment:
		op := c.Operation().Body.MustPathPaymentOp()
		details["from"] = source.Address()
		details["to"] = op.Destination.Address()

		result := c.OperationResult().MustTr().MustPathPaymentResult()

		details["amount"] = amount.String(op.DestAmount)
		details["source_amount"] = amount.String(result.SendAmount())
		details["source_max"] = amount.String(op.SendMax)
		c.assetDetails(details, op.DestAsset, "")
		c.assetDetails(details, op.SendAsset, "source_")

		var path = make([]map[string]interface{}, len(op.Path))
		for i := range op.Path {
			path[i] = make(map[string]interface{})
			c.assetDetails(path[i], op.Path[i], "")
		}
		details["path"] = path
	case xdr.OperationTypeManageOffer:
		op := c.Operation().Body.MustManageOfferOp()
		details["offer_id"] = op.OfferId
		details["amount"] = amount.String(op.Amount)
		details["price"] = op.Price.String()
		details["price_r"] = map[string]interface{}{
			"n": op.Price.N,
			"d": op.Price.D,
		}
		c.assetDetails(details, op.Buying, "buying_")
		c.assetDetails(details, op.Selling, "selling_")

	case xdr.OperationTypeCreatePassiveOffer:
		op := c.Operation().Body.MustCreatePassiveOfferOp()
		details["amount"] = amount.String(op.Amount)
		details["price"] = op.Price.String()
		details["price_r"] = map[string]interface{}{
			"n": op.Price.N,
			"d": op.Price.D,
		}
		c.assetDetails(details, op.Buying, "buying_")
		c.assetDetails(details, op.Selling, "selling_")
	case xdr.OperationTypeSetOptions:
		op := c.Operation().Body.MustSetOptionsOp()

		if op.InflationDest != nil {
			details["inflation_dest"] = op.InflationDest.Address()
		}

		if op.SetFlags != nil && *op.SetFlags > 0 {
			c.flagDetails(details, int32(*op.SetFlags), "set")
		}

		if op.ClearFlags != nil && *op.ClearFlags > 0 {
			c.flagDetails(details, int32(*op.ClearFlags), "clear")
		}

		if op.MasterWeight != nil {
			details["master_key_weight"] = *op.MasterWeight
		}

		if op.LowThreshold != nil {
			details["low_threshold"] = *op.LowThreshold
		}

		if op.MedThreshold != nil {
			details["med_threshold"] = *op.MedThreshold
		}

		if op.HighThreshold != nil {
			details["high_threshold"] = *op.HighThreshold
		}

		if op.HomeDomain != nil {
			details["home_domain"] = *op.HomeDomain
		}

		if op.Signer != nil {
			details["signer_key"] = op.Signer.PubKey.Address()
			details["signer_weight"] = op.Signer.Weight
		}
	case xdr.OperationTypeChangeTrust:
		op := c.Operation().Body.MustChangeTrustOp()
		c.assetDetails(details, op.Line, "")
		details["trustor"] = source.Address()
		details["trustee"] = details["asset_issuer"]
		details["limit"] = amount.String(op.Limit)
	case xdr.OperationTypeAllowTrust:
		op := c.Operation().Body.MustAllowTrustOp()
		c.assetDetails(details, op.Asset.ToAsset(source), "")
		details["trustee"] = source.Address()
		details["trustor"] = op.Trustor.Address()
		details["authorize"] = op.Authorize
	case xdr.OperationTypeAccountMerge:
		aid := c.Operation().Body.MustDestination()
		details["account"] = source.Address()
		details["into"] = aid.Address()
	case xdr.OperationTypeInflation:
		// no inflation details, presently
	case xdr.OperationTypeManageData:
		op := c.Operation().Body.MustManageDataOp()
		details["name"] = string(op.DataName)
		if op.DataValue != nil {
			details["value"] = base64.StdEncoding.EncodeToString(*op.DataValue)
		} else {
			details["value"] = nil
		}
	default:
		panic(fmt.Errorf("Unknown operation type: %s", c.OperationType()))
	}

	return details
}

// OperationID returns the current operations id, as used by the history system.
func (c *Cursor) OperationID() int64 {
	return toid.New(c.lg, int32(c.tx), int32(c.op)).ToInt64()
}

// OperationOrder returns the order of the current operation amongst the
// current transaction's operations.
func (c *Cursor) OperationOrder() int32 {
	return int32(c.op)
}

// OperationResult returns the current operation's result record
func (c *Cursor) OperationResult() *xdr.OperationResult {
	txr := &c.data.Transactions[c.tx].Result.Result
	return &txr.Result.MustResults()[c.op]
}

// OperationSourceAccount returns the current operation's effective source
// account (i.e. default's to the transaction's source account).
func (c *Cursor) OperationSourceAccount() xdr.AccountId {
	aid := c.Operation().SourceAccount
	if aid != nil {
		return *aid
	}

	return c.TransactionSourceAccount()
}

// OperationSourceAddress returns the current operation's effective source
// address (i.e. default's to the transaction's source account).
func (c *Cursor) OperationSourceAddress() string {
	op := c.Operation().SourceAccount
	if op != nil {
		return op.Address()
	}
	tx := c.TransactionSourceAccount()
	return tx.Address()
}

// OperationType returns the current operation type
func (c *Cursor) OperationType() xdr.OperationType {
	return c.Operation().Body.Type
}

// Operations returns the current transactions operations.
func (c *Cursor) Operations() []xdr.Operation {
	return c.data.Transactions[c.tx].Envelope.Tx.Operations
}

// Transaction returns the current transaction
func (c *Cursor) Transaction() *core.Transaction {
	return &c.data.Transactions[c.tx]
}

// TransactionAndFee returns the txhistory and txfeehistory rows for the current
// transaction.
func (c *Cursor) TransactionAndFee() (*core.Transaction, *core.TransactionFee) {
	return &c.data.Transactions[c.tx], &c.data.TransactionFees[c.tx]
}

// TransactionCount returns the count of transactions in the current ledger
func (c *Cursor) TransactionCount() int {
	return len(c.data.Transactions)
}

// TransactionID returns the current tranaction's id, as used by the history
// system.
func (c *Cursor) TransactionID() int64 {
	return toid.New(c.lg, int32(c.tx), 0).ToInt64()
}

// TransactionSourceAccount returns the current transaction's source account id
func (c *Cursor) TransactionSourceAccount() xdr.AccountId {
	return c.Transaction().Envelope.Tx.SourceAccount
}

// assetDetails sets the details for `a` on `result` using keys with `prefix`
func (c *Cursor) assetDetails(result map[string]interface{}, a xdr.Asset, prefix string) error {
	var (
		t    string
		code string
		i    string
	)
	err := a.Extract(&t, &code, &i)
	if err != nil {
		return err
	}
	result[prefix+"asset_type"] = t

	if a.Type == xdr.AssetTypeAssetTypeNative {
		return nil
	}

	result[prefix+"asset_code"] = code
	result[prefix+"asset_issuer"] = i
	return nil
}

// flagDetails sets the account flag details for `f` on `result`.
func (c *Cursor) flagDetails(result map[string]interface{}, f int32, prefix string) {
	var (
		n []int32
		s []string
	)

	if (f & int32(xdr.AccountFlagsAuthRequiredFlag)) > 0 {
		n = append(n, int32(xdr.AccountFlagsAuthRequiredFlag))
		s = append(s, "auth_required")
	}

	if (f & int32(xdr.AccountFlagsAuthRevocableFlag)) > 0 {
		n = append(n, int32(xdr.AccountFlagsAuthRevocableFlag))
		s = append(s, "auth_revocable")
	}

	if (f & int32(xdr.AccountFlagsAuthImmutableFlag)) > 0 {
		n = append(n, int32(xdr.AccountFlagsAuthImmutableFlag))
		s = append(s, "auth_immutable")
	}

	result[prefix+"_flag"] = n
	result[prefix+"_flag_s"] = s
}
