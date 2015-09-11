package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

var effectResourceTypeNames = map[int32]string{
	db.EffectAccountCreated:           "account_created",
	db.EffectAccountRemoved:           "account_removed",
	db.EffectAccountCredited:          "account_credited",
	db.EffectAccountDebited:           "account_debited",
	db.EffectAccountThresholdsUpdated: "account_thresholds_updated",
	db.EffectAccountHomeDomainUpdated: "account_home_domain_updated",
	db.EffectAccountFlagsUpdated:      "account_flags_updated",
	db.EffectSignerCreated:            "signer_created",
	db.EffectSignerRemoved:            "signer_removed",
	db.EffectSignerUpdated:            "signer_updated",
	db.EffectTrustlineCreated:         "trustline_created",
	db.EffectTrustlineRemoved:         "trustline_removed",
	db.EffectTrustlineUpdated:         "trustline_updated",
	db.EffectTrustlineAuthorized:      "trustline_authorized",
	db.EffectTrustlineDeauthorized:    "trustline_deauthorized",
	db.EffectOfferCreated:             "offer_created",
	db.EffectOfferRemoved:             "offer_removed",
	db.EffectOfferUpdated:             "offer_updated",
	db.EffectTrade:                    "trade",
}

// EffectResource is the json form of a row from the history_effects
// table.
type EffectResource map[string]interface{}

// NewEffectResource initializes a new resource from an EffectRecord
func NewEffectResource(op db.EffectRecord) (EffectResource, error) {
	result, err := op.Details()

	if err != nil {
		return nil, err
	}

	if result == nil {
		result = make(map[string]interface{})
	}

	result["_links"] = halgo.Links{}.
		Link("precedes", "/effects?cursor=%s&order=asc", op.PagingToken()).
		Link("succeeds", "/effects?cursor=%s&order=desc", op.PagingToken()).
		Link("operation", "/operations/%d", op.HistoryOperationID).
		Items
	result["paging_token"] = op.PagingToken()
	result["type"] = op.Type
	result["account"] = op.Account

	ts, ok := effectResourceTypeNames[op.Type]

	if ok {
		result["type_s"] = ts
	} else {
		//TODO: log a warning when we encounter this... it implies our code is out of date
		result["type_s"] = "unknown"
	}

	return result, nil
}

// NewEffectResourcePage initialzed a hal.Page from s a slice of
// EffectRecords
func NewEffectResourcePage(records []db.EffectRecord, query db.PageQuery, path string) (hal.Page, error) {
	fmts := path + "?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		r, err := NewEffectResource(record)
		if err != nil {
			return hal.Page{}, err
		}
		resources[i] = r
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
