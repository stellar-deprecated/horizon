package ingest

import (
	"encoding/base64"
	"fmt"

	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/ingest/participants"
	// "github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
)

// Run starts an attempt to ingest the range of ledgers specified in this
// session.
func (is *Session) Run() {
	is.Err = is.Ingestion.Start()
	if is.Err != nil {
		return
	}

	for is.Cursor.NextLedger() {
		if is.Err != nil {
			return
		}

		is.clearLedger()
		is.ingestLedger()
		is.flush()
	}

	if is.Err != nil {
		is.Ingestion.Rollback()
		return
	}

	is.Err = is.Ingestion.Close()

	// TODO: metrics
	// TODO: validate ledger chain
	// TODO: clear data
	// TODO: record success

}

func (is *Session) clearLedger() {
	if is.Err != nil {
		return
	}

	if !is.ClearExisting {
		return
	}

	is.Err = is.Ingestion.Clear(is.Cursor.LedgerRange())
}

func (is *Session) effectFlagDetails(flagDetails map[string]bool, flagPtr *xdr.Uint32, setValue bool) {
	if flagPtr != nil {
		flags := xdr.AccountFlags(*flagPtr)

		if flags&xdr.AccountFlagsAuthRequiredFlag != 0 {
			flagDetails["auth_required"] = setValue
		}
		if flags&xdr.AccountFlagsAuthRevocableFlag != 0 {
			flagDetails["auth_revocable"] = setValue
		}
		if flags&xdr.AccountFlagsAuthImmutableFlag != 0 {
			flagDetails["auth_immutable"] = setValue
		}
	}
}

func (is *Session) flush() {
	if is.Err != nil {
		return
	}
	is.Err = is.Ingestion.Flush()
}

func (is *Session) ingestEffects() {
	if is.Err != nil {
		return
	}

	effects := &EffectIngestion{
		Dest:        is.Ingestion,
		Accounts:    is.accountCache,
		OperationID: is.Cursor.OperationID(),
	}
	source := is.Cursor.TransactionSourceAccount()
	opbody := is.Cursor.Operation().Body

	switch is.Cursor.OperationType() {
	case xdr.OperationTypeCreateAccount:
		op := opbody.MustCreateAccountOp()

		effects.Add(op.Destination, history.EffectAccountCreated,
			map[string]interface{}{
				"starting_balance": amount.String(op.StartingBalance),
			},
		)

		effects.Add(source, history.EffectAccountDebited,
			map[string]interface{}{
				"asset_type": "native",
				"amount":     amount.String(op.StartingBalance),
			},
		)

		effects.Add(op.Destination, history.EffectSignerCreated,
			map[string]interface{}{
				"public_key": op.Destination.Address(),
				"weight":     keypair.DefaultSignerWeight,
			},
		)

	case xdr.OperationTypePayment:
		op := opbody.MustPaymentOp()
		dets := map[string]interface{}{"amount": amount.String(op.Amount)}
		is.assetDetails(dets, op.Asset, "")
		effects.Add(op.Destination, history.EffectAccountCredited, dets)
		effects.Add(source, history.EffectAccountDebited, dets)
	case xdr.OperationTypePathPayment:
		op := opbody.MustPathPaymentOp()
		dets := map[string]interface{}{"amount": amount.String(op.DestAmount)}
		is.assetDetails(dets, op.DestAsset, "")
		effects.Add(op.Destination, history.EffectAccountCredited, dets)

		result := is.Cursor.OperationResult().MustPathPaymentResult()
		dets = map[string]interface{}{"amount": amount.String(result.SendAmount())}
		is.assetDetails(dets, op.SendAsset, "")
		effects.Add(source, history.EffectAccountDebited, dets)
		is.ingestTrades(effects, source, result.MustSuccess().Offers)
	case xdr.OperationTypeManageOffer:
		result := is.Cursor.OperationResult().MustManageOfferResult().MustSuccess()
		is.ingestTrades(effects, source, result.OffersClaimed)
	case xdr.OperationTypeCreatePassiveOffer:
		claims := []xdr.ClaimOfferAtom{}
		result := is.Cursor.OperationResult()

		// KNOWN ISSUE:  stellar-core creates results for CreatePassiveOffer operations
		// with the wrong result arm set.
		if result.Type == xdr.OperationTypeManageOffer {
			claims = result.MustManageOfferResult().MustSuccess().OffersClaimed
		} else {
			claims = result.MustCreatePassiveOfferResult().MustSuccess().OffersClaimed
		}

		is.ingestTrades(effects, source, claims)
	case xdr.OperationTypeSetOptions:
		op := opbody.MustSetOptionsOp()

		if op.HomeDomain != nil {
			effects.Add(source, history.EffectAccountHomeDomainUpdated,
				map[string]interface{}{
					"home_domain": string(*op.HomeDomain),
				},
			)
		}

		thresholdDetails := map[string]interface{}{}

		if op.LowThreshold != nil {
			thresholdDetails["low_threshold"] = *op.LowThreshold
		}

		if op.MedThreshold != nil {
			thresholdDetails["med_threshold"] = *op.MedThreshold
		}

		if op.HighThreshold != nil {
			thresholdDetails["high_threshold"] = *op.HighThreshold
		}

		if len(thresholdDetails) > 0 {
			effects.Add(source, history.EffectAccountThresholdsUpdated, thresholdDetails)
		}

		flagDetails := map[string]bool{}
		is.effectFlagDetails(flagDetails, op.SetFlags, true)
		is.effectFlagDetails(flagDetails, op.ClearFlags, false)

		if len(flagDetails) > 0 {
			effects.Add(source, history.EffectAccountFlagsUpdated, flagDetails)
		}

		is.ingestSignerEffects(effects, op)

	case xdr.OperationTypeChangeTrust:
		op := opbody.MustChangeTrustOp()
		dets := map[string]interface{}{
			"limit": amount.String(op.Limit),
		}
		is.assetDetails(dets, op.Line, "")
		var change *xdr.LedgerEntryChange
		var effect history.EffectType

		for _, c := range is.Cursor.OperationChanges() {
			if c.EntryType() == xdr.LedgerEntryTypeTrustline {
				change = &c
				break
			}
		}

		if change == nil {
			panic("failed to find meta entry when ingesting effects for ChangeTrustOp")
		}

		switch change.Type {
		case xdr.LedgerEntryChangeTypeLedgerEntryCreated:
			effect = history.EffectTrustlineCreated
		case xdr.LedgerEntryChangeTypeLedgerEntryRemoved:
			effect = history.EffectTrustlineRemoved
		case xdr.LedgerEntryChangeTypeLedgerEntryUpdated:
			effect = history.EffectTrustlineUpdated
		case xdr.LedgerEntryChangeTypeLedgerEntryState:
			effect = history.EffectTrustlineUpdated
		}

		effects.Add(source, effect, dets)
	case xdr.OperationTypeAllowTrust:
		op := opbody.MustAllowTrustOp()
		asset := op.Asset.ToAsset(source)
		dets := map[string]interface{}{
			"trustor": op.Trustor.Address(),
		}
		is.assetDetails(dets, asset, "")

		if op.Authorize {
			effects.Add(source, history.EffectTrustlineAuthorized, dets)
		} else {
			effects.Add(source, history.EffectTrustlineDeauthorized, dets)
		}

	case xdr.OperationTypeAccountMerge:
		dest := opbody.MustDestination()
		result := is.Cursor.OperationResult().MustAccountMergeResult()
		dets := map[string]interface{}{
			"amount":     amount.String(result.MustSourceAccountBalance()),
			"asset_type": "native",
		}
		effects.Add(source, history.EffectAccountDebited, dets)
		effects.Add(dest, history.EffectAccountCredited, dets)
		effects.Add(source, history.EffectAccountRemoved, map[string]interface{}{})
	case xdr.OperationTypeInflation:
		payouts := is.Cursor.OperationResult().MustInflationResult().MustPayouts()
		for _, payout := range payouts {
			effects.Add(payout.Destination, history.EffectAccountCredited,
				map[string]interface{}{
					"amount":     amount.String(payout.Amount),
					"asset_type": "native",
				},
			)
		}
	case xdr.OperationTypeManageData:
		op := opbody.MustManageDataOp()
		dets := map[string]interface{}{
			"name": op.DataName,
		}
		var change *xdr.LedgerEntryChange
		var effect history.EffectType

		for _, c := range is.Cursor.OperationChanges() {
			if c.EntryType() == xdr.LedgerEntryTypeData {
				change = &c
				break
			}
		}

		if change == nil {
			panic("failed to find meta entry when ingesting effects for ManageDataOp")
		}

		switch change.Type {
		case xdr.LedgerEntryChangeTypeLedgerEntryCreated:
			effect = history.EffectDataCreated
			dets["value"] = *op.DataValue
		case xdr.LedgerEntryChangeTypeLedgerEntryRemoved:
			effect = history.EffectDataRemoved
		case xdr.LedgerEntryChangeTypeLedgerEntryUpdated:
			effect = history.EffectDataUpdated
			dets["value"] = *op.DataValue
		case xdr.LedgerEntryChangeTypeLedgerEntryState:
			effect = history.EffectDataUpdated
			dets["value"] = *op.DataValue
		}

		effects.Add(source, effect, dets)

	default:
		is.Err = fmt.Errorf("Unknown operation type: %s", is.Cursor.OperationType())
		return
	}

	is.Err = effects.Finish()
}

// ingestLedger ingests the current ledger
func (is *Session) ingestLedger() {
	if is.Err != nil {
		return
	}

	is.Ingestion.Ledger(
		is.Cursor.LedgerID(),
		is.Cursor.Ledger(),
		is.Cursor.SuccessfulTransactionCount(),
		is.Cursor.SuccessfulLedgerOperationCount(),
	)

	// If this is ledger 1, create the root account
	if is.Cursor.LedgerSequence() == 1 {
		is.Ingestion.Account(1, keypair.Master(is.Network).Address())
	}

	for is.Cursor.NextTx() {
		is.ingestTransaction()
	}

	is.Ingested++

	return
}

func (is *Session) ingestOperation() {
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.Operation(
		is.Cursor.OperationID(),
		is.Cursor.TransactionID(),
		is.Cursor.OperationOrder(),
		is.Cursor.OperationSourceAccount(),
		is.Cursor.OperationType(),
		is.operationDetails(),
	)
	if is.Err != nil {
		return
	}

	// Import the new account if one was created
	if is.Cursor.Operation().Body.Type == xdr.OperationTypeCreateAccount {
		op := is.Cursor.Operation().Body.MustCreateAccountOp()
		is.Err = is.Ingestion.Account(is.Cursor.OperationID(), op.Destination.Address())
	}

	is.ingestOperationParticipants()
	is.ingestEffects()
}

func (is *Session) ingestOperationParticipants() {
	if is.Err != nil {
		return
	}

	// Find the participants
	var p []xdr.AccountId
	p, is.Err = participants.ForOperation(
		&is.Cursor.Transaction().Envelope.Tx,
		is.Cursor.Operation(),
	)
	if is.Err != nil {
		return
	}

	var aids []int64
	aids, is.Err = is.lookupParticipantIDs(p)
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.OperationParticipants(is.Cursor.OperationID(), aids)
	if is.Err != nil {
		return
	}
}

func (is *Session) ingestSignerEffects(effects *EffectIngestion, op xdr.SetOptionsOp) {
	// TODO: differentiate added/update correctly

	// ingest master signer effects
	if op.MasterWeight != nil {
		effect := history.EffectSignerCreated
		if *op.MasterWeight == 0 {
			effect = history.EffectSignerRemoved
		}
		source := is.Cursor.OperationSourceAccount()
		effects.Add(source, effect, is.signerDetails(source, int32(*op.MasterWeight)))
	}

	// ingest non-master signer effects
	if op.Signer != nil {
		effect := history.EffectSignerCreated
		if op.Signer.Weight == 0 {
			effect = history.EffectSignerRemoved
		}
		source := is.Cursor.OperationSourceAccount()
		effects.Add(source, effect, is.signerDetails(op.Signer.PubKey, int32(op.Signer.Weight)))
	}
}

func (is *Session) ingestTrades(effects *EffectIngestion, buyer xdr.AccountId, claims []xdr.ClaimOfferAtom) {
	for _, claim := range claims {
		seller := claim.SellerId
		bd, sd := is.tradeDetails(buyer, seller, claim)
		effects.Add(buyer, history.EffectTrade, bd)
		effects.Add(seller, history.EffectTrade, sd)
	}
}

func (is *Session) signerDetails(key xdr.AccountId, weight int32) map[string]interface{} {
	return map[string]interface{}{
		"public_key": key.Address(),
		"weight":     weight,
	}
}

func (is *Session) tradeDetails(buyer, seller xdr.AccountId, claim xdr.ClaimOfferAtom) (bd map[string]interface{}, sd map[string]interface{}) {
	bd = map[string]interface{}{
		"offer_id":      claim.OfferId,
		"seller":        seller.Address(),
		"bought_amount": amount.String(claim.AmountSold),
		"sold_amount":   amount.String(claim.AmountBought),
	}
	is.assetDetails(bd, claim.AssetSold, "bought_")
	is.assetDetails(bd, claim.AssetBought, "sold_")

	sd = map[string]interface{}{
		"offer_id":      claim.OfferId,
		"seller":        buyer.Address(),
		"bought_amount": amount.String(claim.AmountBought),
		"sold_amount":   amount.String(claim.AmountSold),
	}
	is.assetDetails(sd, claim.AssetBought, "bought_")
	is.assetDetails(sd, claim.AssetSold, "sold_")

	return
}

func (is *Session) ingestTransaction() {
	if is.Err != nil {
		return
	}

	// skip ingesting failed transactions
	if !is.Cursor.Transaction().IsSuccessful() {
		return
	}

	is.Ingestion.Transaction(
		is.Cursor.TransactionID(),
		is.Cursor.Transaction(),
		is.Cursor.TransactionFee(),
	)

	for is.Cursor.NextOp() {
		is.ingestOperation()
	}

	is.ingestTransactionParticipants()
}

func (is *Session) ingestTransactionParticipants() {
	if is.Err != nil {
		return
	}

	// Find the participants
	var p []xdr.AccountId
	p, is.Err = participants.ForTransaction(
		&is.Cursor.Transaction().Envelope.Tx,
		&is.Cursor.Transaction().ResultMeta,
		&is.Cursor.TransactionFee().Changes,
	)
	if is.Err != nil {
		return
	}

	var aids []int64
	aids, is.Err = is.lookupParticipantIDs(p)
	if is.Err != nil {
		return
	}

	is.Err = is.Ingestion.TransactionParticipants(is.Cursor.TransactionID(), aids)
	if is.Err != nil {
		return
	}

}

func (is *Session) lookupParticipantIDs(aids []xdr.AccountId) (ret []int64, err error) {
	found := map[int64]bool{}

	for _, in := range aids {
		var out int64
		out, err = is.accountCache.Get(in.Address())
		if err != nil {
			return
		}

		// De-duplicate
		if _, ok := found[out]; ok {
			continue
		}

		found[out] = true
		ret = append(ret, out)
	}

	return
}

// assetDetails sets the details for `a` on `result` using keys with `prefix`
func (is *Session) assetDetails(result map[string]interface{}, a xdr.Asset, prefix string) error {
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

// operationDetails returns the details regarding the current operation, suitable
// for ingestion into a history_operation row
func (is *Session) operationDetails() map[string]interface{} {
	details := map[string]interface{}{}
	c := is.Cursor
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
		is.assetDetails(details, op.Asset, "")
	case xdr.OperationTypePathPayment:
		op := c.Operation().Body.MustPathPaymentOp()
		details["from"] = source.Address()
		details["to"] = op.Destination.Address()

		result := c.OperationResult().MustPathPaymentResult()

		details["amount"] = amount.String(op.DestAmount)
		details["source_amount"] = amount.String(result.SendAmount())
		details["source_max"] = amount.String(op.SendMax)
		is.assetDetails(details, op.DestAsset, "")
		is.assetDetails(details, op.SendAsset, "source_")

		var path = make([]map[string]interface{}, len(op.Path))
		for i := range op.Path {
			path[i] = make(map[string]interface{})
			is.assetDetails(path[i], op.Path[i], "")
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
		is.assetDetails(details, op.Buying, "buying_")
		is.assetDetails(details, op.Selling, "selling_")

	case xdr.OperationTypeCreatePassiveOffer:
		op := c.Operation().Body.MustCreatePassiveOfferOp()
		details["amount"] = amount.String(op.Amount)
		details["price"] = op.Price.String()
		details["price_r"] = map[string]interface{}{
			"n": op.Price.N,
			"d": op.Price.D,
		}
		is.assetDetails(details, op.Buying, "buying_")
		is.assetDetails(details, op.Selling, "selling_")
	case xdr.OperationTypeSetOptions:
		op := c.Operation().Body.MustSetOptionsOp()

		if op.InflationDest != nil {
			details["inflation_dest"] = op.InflationDest.Address()
		}

		if op.SetFlags != nil && *op.SetFlags > 0 {
			is.operationFlagDetails(details, int32(*op.SetFlags), "set")
		}

		if op.ClearFlags != nil && *op.ClearFlags > 0 {
			is.operationFlagDetails(details, int32(*op.ClearFlags), "clear")
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
		is.assetDetails(details, op.Line, "")
		details["trustor"] = source.Address()
		details["trustee"] = details["asset_issuer"]
		details["limit"] = amount.String(op.Limit)
	case xdr.OperationTypeAllowTrust:
		op := c.Operation().Body.MustAllowTrustOp()
		is.assetDetails(details, op.Asset.ToAsset(source), "")
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

// operationFlagDetails sets the account flag details for `f` on `result`.
func (is *Session) operationFlagDetails(result map[string]interface{}, f int32, prefix string) {
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
