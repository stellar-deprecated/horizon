package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/render/hal"
)

var effectResourceTypeNames = map[int32]string{
	// account effects
	0: "account_created",             // from create_account
	1: "account_removed",             // from merge_account
	2: "account_credited",            // from create_account, payment, path_payment, merge_account
	3: "account_debited",             // from create_account, payment, path_payment, create_account
	4: "account_thresholds_updated",  // from set_options
	5: "account_home_domain_updated", // from set_options
	6: "account_flags_updated",       // from set_options

	// signer effects
	10: "signer_created", // from set_options
	11: "signer_removed", // from set_options
	12: "signer_updated", // from set_options

	// trustline effects
	20: "trustline_created",      // from change_trust
	21: "trustline_removed",      // from change_trust
	22: "trustline_updated",      // from change_trust, allow_trust
	23: "trustline_authorized",   // from allow_trust
	24: "trustline_deauthorized", // from allow_trust

	// trading effects
	30: "offer_created", // from manage_offer, creat_passive_offer
	31: "offer_removed", // from manage_offer, creat_passive_offer, path_payment
	32: "offer_updated", // from manage_offer, creat_passive_offer, path_payment
	33: "trade",         // from manage_offer, creat_passive_offer, path_payment
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
